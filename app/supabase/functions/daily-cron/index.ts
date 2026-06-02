// =============================================================================
// EDGE FUNCTION: daily-cron
// Orquestrador diário — chama as outras 3 functions em sequência.
// Acionada por GitHub Actions (cron) uma vez por dia.
// =============================================================================
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { supabaseAdmin } from "../_shared/supabase.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
  const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const results: Record<string, unknown> = {};

  async function call(fn: string, body: Record<string, unknown> = {}) {
    const res = await fetch(`${SUPABASE_URL}/functions/v1/${fn}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${SERVICE_KEY}`,
      },
      body: JSON.stringify(body),
    });
    return await res.json();
  }

  try {
    // 1) Recorrências
    results.recurring = await call("process-recurring");

    // 2) Parcelas CPI
    results.cpi = await call("check-cpi");

    // 3) Faturas vencendo hoje
    const today = new Date().toISOString().split("T")[0];
    const { data: dueInvoices } = await supabaseAdmin
      .from("invoices")
      .select("id")
      .lte("due_date", today)
      .eq("status", "open");

    results.invoices_paid = [];
    for (const inv of dueInvoices ?? []) {
      const r = await call("pay-invoice", { invoice_id: inv.id });
      (results.invoices_paid as unknown[]).push(r);
    }

    return new Response(
      JSON.stringify({ success: true, executed_at: new Date().toISOString(), results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message, partial: results }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
