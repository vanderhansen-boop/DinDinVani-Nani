// Edge Function: recalculate_score
// Roda diariamente. Recalcula o Score Paz Financeira de cada familia
// usando os pesos configurados na tabela score_settings (15b).
//
// Componentes (peso default em parenteses):
//  - cobertura_cf       (25) : saldo CF / fatura aberta
//  - cobertura_cpi      (20) : reservas CPI / parcelas futuras
//  - aderencia_orcamento(20) : gasto real vs monthly_budgets
//  - reserva_emergencia (20) : CE / 6x necessidades mensais
//  - regularidade       (15) : tx de lancamentos nos ultimos 30 dias
// Score final 0..100.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createServiceClient, logAudit } from "../_shared/supabase_client.ts";

function clamp(n: number, min = 0, max = 1) {
  return Math.max(min, Math.min(max, n));
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createServiceClient();
    const hoje = new Date();
    const mesAtual = hoje.toISOString().slice(0, 7);

    const { data: familias, error: errF } = await supabase
      .from("families")
      .select("id");
    if (errF) throw errF;

    const resultados: unknown[] = [];

    for (const fam of familias ?? []) {
      // Buscar pesos configurados (score_settings)
      const { data: cfg } = await supabase
        .from("score_settings")
        .select("*")
        .eq("family_id", fam.id)
        .single();

      const pesos = {
        cf:    cfg?.peso_cobertura_cf       ?? 25,
        cpi:   cfg?.peso_cobertura_cpi      ?? 20,
        orc:   cfg?.peso_aderencia_orcamento?? 20,
        ce:    cfg?.peso_reserva_emergencia ?? 20,
        reg:   cfg?.peso_regularidade       ?? 15,
      };

      // --- 1. Cobertura CF ---
      const { data: cfs } = await supabase
        .from("piggy_banks")
        .select("current_balance")
        .eq("family_id", fam.id).eq("type", "CF");
      const saldoCF = (cfs ?? []).reduce((a, x) => a + Number(x.current_balance), 0);

      const { data: faturasAbertas } = await supabase
        .from("invoices")
        .select("total_amount")
        .eq("family_id", fam.id).eq("status", "open");
      const faturaAberta = (faturasAbertas ?? []).reduce(
        (a, x) => a + Number(x.total_amount), 0);

      const cobCF = faturaAberta > 0 ? clamp(saldoCF / faturaAberta) : 1;

      // --- 2. Cobertura CPI ---
      const { data: parcelasFut } = await supabase
        .from("cpi_installment_payments")
        .select("amount")
        .eq("family_id", fam.id).eq("status", "pending");
      const totalParcelas = (parcelasFut ?? []).reduce(
        (a, x) => a + Number(x.amount), 0);

      const { data: reservasCpi } = await supabase
        .from("piggy_bank_reservations")
        .select("reserved_amount, released_amount")
        .eq("family_id", fam.id);
      const reservasSaldo = (reservasCpi ?? []).reduce(
        (a, x) => a + (Number(x.reserved_amount) - Number(x.released_amount)), 0);

      const cobCPI = totalParcelas > 0 ? clamp(reservasSaldo / totalParcelas) : 1;

      // --- 3. Aderencia orcamento ---
      const { data: orc } = await supabase
        .from("monthly_budgets")
        .select("needs_amount, wants_amount, savings_amount, base_income")
        .eq("family_id", fam.id).eq("month", mesAtual).maybeSingle();

      let aderencia = 1;
      if (orc) {
        const mesIni = `${mesAtual}-01`;
        const { data: gastos } = await supabase
          .from("transactions")
          .select("amount")
          .eq("family_id", fam.id).eq("type", "expense")
          .gte("date", mesIni);
        const gastoTotal = (gastos ?? []).reduce((a, x) => a + Number(x.amount), 0);
        const orcamentoTotal = Number(orc.needs_amount) + Number(orc.wants_amount);
        aderencia = orcamentoTotal > 0
          ? clamp(1 - Math.max(0, gastoTotal - orcamentoTotal) / orcamentoTotal)
          : 1;
      }

      // --- 4. Reserva emergencia ---
      const { data: cEmergencia } = await supabase
        .from("piggy_banks")
        .select("current_balance")
        .eq("family_id", fam.id).eq("type", "CE");
      const saldoCE = (cEmergencia ?? []).reduce(
        (a, x) => a + Number(x.current_balance), 0);
      const necessidadesMes = Number(orc?.needs_amount ?? 0);
      const metaCE = necessidadesMes * 6;
      const cobCE = metaCE > 0 ? clamp(saldoCE / metaCE) : (saldoCE > 0 ? 1 : 0);

      // --- 5. Regularidade ---
      const trintaDiasAtras = new Date(hoje.getTime() - 30 * 86400000)
        .toISOString().slice(0, 10);
      const { count: lancamentos } = await supabase
        .from("transactions")
        .select("id", { count: "exact", head: true })
        .eq("family_id", fam.id)
        .gte("date", trintaDiasAtras);
      const regular = clamp((lancamentos ?? 0) / 30); // 1 por dia = 100%

      // --- Score final ---
      const score = Math.round(
        cobCF * pesos.cf +
        cobCPI * pesos.cpi +
        aderencia * pesos.orc +
        cobCE * pesos.ce +
        regular * pesos.reg
      );

      // Persistir em family_settings (campo score_atual + score_breakdown jsonb)
      await supabase.from("family_settings").upsert({
        family_id: fam.id,
        score_atual: score,
        score_breakdown: {
          cobertura_cf: Math.round(cobCF * 100),
          cobertura_cpi: Math.round(cobCPI * 100),
          aderencia_orcamento: Math.round(aderencia * 100),
          reserva_emergencia: Math.round(cobCE * 100),
          regularidade: Math.round(regular * 100),
          pesos,
        },
        score_updated_at: new Date().toISOString(),
      }, { onConflict: "family_id" });

      await logAudit(supabase, fam.id, "score_recalculated", { score });
      resultados.push({ familia: fam.id, score });
    }

    return new Response(
      JSON.stringify({ ok: true, processadas: resultados.length, resultados }),
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
