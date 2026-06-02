// =============================================================================
// EDGE FUNCTION: check-cpi
// Para cada CPI ativa, transfere o valor da parcela do mês para a CF do cartão.
// Mantém o princípio: CPI guarda total, CF paga fatura.
// =============================================================================
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const today = new Date().toISOString().split("T")[0];

    // Busca parcelas CPI pendentes com data <= hoje
    const { data: installments, error } = await supabaseAdmin
      .from("cpi_installment_payments")
      .select("*, piggy_banks!inner(*)")
      .lte("due_date", today)
      .eq("status", "pending");

    if (error) throw error;

    let processed = 0;

    for (const inst of installments ?? []) {
      const cpi = inst.piggy_banks;

      // CF vinculada ao mesmo cartão da CPI
      const { data: cf } = await supabaseAdmin
        .from("piggy_banks")
        .select("*")
        .eq("credit_card_id", cpi.credit_card_id)
        .eq("type", "CF")
        .single();

      if (!cf) continue;

      // Debita CPI, credita CF
      await supabaseAdmin
        .from("piggy_banks")
        .update({ current_balance: Number(cpi.current_balance) - Number(inst.amount) })
        .eq("id", cpi.id);

      await supabaseAdmin
        .from("piggy_banks")
        .update({ current_balance: Number(cf.current_balance) + Number(inst.amount) })
        .eq("id", cf.id);

      await supabaseAdmin
        .from("cpi_installment_payments")
        .update({ status: "paid", paid_at: new Date().toISOString() })
        .eq("id", inst.id);

      processed++;
    }

    return new Response(
      JSON.stringify({ success: true, processed }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
