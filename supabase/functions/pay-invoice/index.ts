// =============================================================================
// EDGE FUNCTION: pay-invoice
// Paga a fatura de um cartão de crédito no vencimento.
// Debita o valor total da Caixinha de Fatura (CF) e marca invoice como "paid".
// =============================================================================
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { invoice_id } = await req.json();

    if (!invoice_id) {
      return new Response(
        JSON.stringify({ error: "invoice_id é obrigatório" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1) Busca fatura
    const { data: invoice, error: invErr } = await supabaseAdmin
      .from("invoices")
      .select("*, credit_cards(*)")
      .eq("id", invoice_id)
      .single();

    if (invErr || !invoice) throw new Error("Fatura não encontrada");
    if (invoice.status === "paid") {
      return new Response(
        JSON.stringify({ message: "Fatura já paga" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2) Busca Caixinha de Fatura (CF) vinculada ao cartão
    const { data: cf, error: cfErr } = await supabaseAdmin
      .from("piggy_banks")
      .select("*")
      .eq("credit_card_id", invoice.credit_card_id)
      .eq("type", "CF")
      .single();

    if (cfErr || !cf) throw new Error("CF do cartão não encontrada");

    // 3) Verifica saldo
    if (Number(cf.current_balance) < Number(invoice.total_amount)) {
      throw new Error(
        `Saldo insuficiente na CF. Disponível: ${cf.current_balance}, necessário: ${invoice.total_amount}`
      );
    }

    // 4) Debita CF
    const newBalance = Number(cf.current_balance) - Number(invoice.total_amount);
    const { error: updCfErr } = await supabaseAdmin
      .from("piggy_banks")
      .update({ current_balance: newBalance })
      .eq("id", cf.id);
    if (updCfErr) throw updCfErr;

    // 5) Marca fatura como paga
    const { error: updInvErr } = await supabaseAdmin
      .from("invoices")
      .update({
        status: "paid",
        paid_at: new Date().toISOString(),
        paid_from_piggy_bank_id: cf.id,
      })
      .eq("id", invoice_id);
    if (updInvErr) throw updInvErr;

    // 6) Log de auditoria
    await supabaseAdmin.from("audit_log").insert({
      family_id: invoice.family_id,
      action: "INVOICE_PAID",
      entity: "invoices",
      entity_id: invoice_id,
      details: { amount: invoice.total_amount, from_cf: cf.id },
    });

    return new Response(
      JSON.stringify({
        success: true,
        invoice_id,
        amount_paid: invoice.total_amount,
        cf_balance_after: newBalance,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
