// Edge Function: pay_invoice_on_due_date
// Roda diariamente. Paga faturas que vencem hoje debitando da Caixinha de Fatura (CF).
// Filosofia CF: cada compra ja reservou valor na CF, entao no vencimento apenas liquidamos.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createServiceClient, logAudit } from "../_shared/supabase_client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createServiceClient();
    const hoje = new Date().toISOString().slice(0, 10);

    // 1. Buscar faturas vencendo hoje e ainda nao pagas
    const { data: faturas, error: errFat } = await supabase
      .from("invoices")
      .select("id, family_id, credit_card_id, total_amount, due_date, status")
      .eq("due_date", hoje)
      .eq("status", "open");

    if (errFat) throw errFat;

    const resultados: unknown[] = [];

    for (const fatura of faturas ?? []) {
      // 2. Localizar CF da familia
      const { data: cf, error: errCf } = await supabase
        .from("piggy_banks")
        .select("id, current_balance")
        .eq("family_id", fatura.family_id)
        .eq("type", "CF")
        .eq("credit_card_id", fatura.credit_card_id)
        .single();

      if (errCf || !cf) {
        resultados.push({ fatura: fatura.id, status: "CF_NAO_ENCONTRADA" });
        continue;
      }

      if (Number(cf.current_balance) < Number(fatura.total_amount)) {
        resultados.push({
          fatura: fatura.id,
          status: "SALDO_INSUFICIENTE",
          saldo: cf.current_balance,
          fatura_valor: fatura.total_amount,
        });
        await logAudit(supabase, fatura.family_id, "invoice_payment_failed", {
          invoice_id: fatura.id,
          reason: "saldo_insuficiente_na_cf",
        });
        continue;
      }

      // 3. Debitar CF (transacao tipo expense)
      const { error: errTx } = await supabase.from("transactions").insert({
        family_id: fatura.family_id,
        type: "expense",
        amount: fatura.total_amount,
        description: `Pagamento fatura ${fatura.id}`,
        piggy_bank_id: cf.id,
        invoice_id: fatura.id,
        date: hoje,
        source: "edge_function",
      });
      if (errTx) throw errTx;

      // 4. Marcar fatura como paga
      const { error: errUp } = await supabase
        .from("invoices")
        .update({ status: "paid", paid_at: new Date().toISOString() })
        .eq("id", fatura.id);
      if (errUp) throw errUp;

      await logAudit(supabase, fatura.family_id, "invoice_paid", {
        invoice_id: fatura.id,
        amount: fatura.total_amount,
        piggy_bank_id: cf.id,
      });

      resultados.push({ fatura: fatura.id, status: "PAGA", valor: fatura.total_amount });
    }

    return new Response(
      JSON.stringify({ ok: true, data: hoje, processadas: resultados.length, resultados }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
