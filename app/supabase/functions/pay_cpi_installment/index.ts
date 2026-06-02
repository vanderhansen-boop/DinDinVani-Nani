// Edge Function: pay_cpi_installment
// Roda diariamente. Processa parcelas CPI que devem ser pagas no mes corrente.
// Filosofia CPI: o valor total ja esta reservado em piggy_bank_reservations.
// Aqui apenas liberamos a parcela do mes para a CF do cartao correspondente.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createServiceClient, logAudit } from "../_shared/supabase_client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createServiceClient();
    const hoje = new Date();
    const mesRef = hoje.toISOString().slice(0, 7); // YYYY-MM

    // 1. Buscar parcelas CPI do mes ainda nao pagas
    const { data: parcelas, error: errP } = await supabase
      .from("cpi_installment_payments")
      .select("id, family_id, reservation_id, installment_number, amount, due_month, status")
      .eq("due_month", mesRef)
      .eq("status", "pending");

    if (errP) throw errP;

    const resultados: unknown[] = [];

    for (const p of parcelas ?? []) {
      // 2. Buscar reserva CPI origem
      const { data: reserva, error: errR } = await supabase
        .from("piggy_bank_reservations")
        .select("id, piggy_bank_id, credit_card_id, reserved_amount, released_amount")
        .eq("id", p.reservation_id)
        .single();

      if (errR || !reserva) {
        resultados.push({ parcela: p.id, status: "RESERVA_NAO_ENCONTRADA" });
        continue;
      }

      // 3. Liberar valor da reserva CPI para a CF do cartao
      const { data: cf } = await supabase
        .from("piggy_banks")
        .select("id")
        .eq("family_id", p.family_id)
        .eq("type", "CF")
        .eq("credit_card_id", reserva.credit_card_id)
        .single();

      if (!cf) {
        resultados.push({ parcela: p.id, status: "CF_NAO_ENCONTRADA" });
        continue;
      }

      // 4. Atualizar released_amount na reserva
      const { error: errUpRes } = await supabase
        .from("piggy_bank_reservations")
        .update({
          released_amount: Number(reserva.released_amount) + Number(p.amount),
        })
        .eq("id", reserva.id);
      if (errUpRes) throw errUpRes;

      // 5. Creditar CF com o valor da parcela
      const { error: errTx } = await supabase.from("transactions").insert({
        family_id: p.family_id,
        type: "transfer",
        amount: p.amount,
        description: `Liberacao CPI parcela ${p.installment_number}`,
        piggy_bank_id: cf.id,
        source: "edge_function",
        date: hoje.toISOString().slice(0, 10),
      });
      if (errTx) throw errTx;

      // 6. Marcar parcela como paga
      const { error: errUpP } = await supabase
        .from("cpi_installment_payments")
        .update({ status: "paid", paid_at: new Date().toISOString() })
        .eq("id", p.id);
      if (errUpP) throw errUpP;

      await logAudit(supabase, p.family_id, "cpi_installment_released", {
        parcela_id: p.id,
        valor: p.amount,
        numero: p.installment_number,
      });

      resultados.push({ parcela: p.id, status: "LIBERADA", valor: p.amount });
    }

    return new Response(
      JSON.stringify({ ok: true, mes: mesRef, processadas: resultados.length, resultados }),
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
