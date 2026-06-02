// =============================================================================
// EDGE FUNCTION: process-recurring
// Processa lançamentos recorrentes (salário, aluguel, assinaturas, etc.)
// Cria transactions para o mês corrente quando next_run_date <= hoje.
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

    // 1) Busca recorrências vencidas
    const { data: recurrings, error } = await supabaseAdmin
      .from("recurring_transactions")
      .select("*")
      .lte("next_run_date", today)
      .eq("active", true);

    if (error) throw error;

    let processed = 0;

    for (const rec of recurrings ?? []) {
      // 2) Cria transação
      const { error: txErr } = await supabaseAdmin.from("transactions").insert({
        family_id: rec.family_id,
        user_id: rec.user_id,
        account_id: rec.account_id,
        category_id: rec.category_id,
        type: rec.type,
        amount: rec.amount,
        description: rec.description,
        transaction_date: today,
        recurring_id: rec.id,
      });
      if (txErr) {
        console.error(`Erro recorrência ${rec.id}:`, txErr.message);
        continue;
      }

      // 3) Calcula próxima execução
      const next = new Date(rec.next_run_date);
      switch (rec.frequency) {
        case "daily":   next.setDate(next.getDate() + 1); break;
        case "weekly":  next.setDate(next.getDate() + 7); break;
        case "monthly": next.setMonth(next.getMonth() + 1); break;
        case "yearly":  next.setFullYear(next.getFullYear() + 1); break;
      }

      await supabaseAdmin
        .from("recurring_transactions")
        .update({ next_run_date: next.toISOString().split("T")[0] })
        .eq("id", rec.id);

      processed++;
    }

    return new Response(
      JSON.stringify({ success: true, processed, total: recurrings?.length ?? 0 }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
