// Edge Function: generate_monthly_budget
// Roda dia 1 de cada mes. Aplica filosofia OD (Orcamento Defasado):
// renda recebida no mes M define o orcamento do mes M+2.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createServiceClient, logAudit } from "../_shared/supabase_client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createServiceClient();
    const hoje = new Date();

    // Mes alvo do orcamento = mes atual (M+2 em relacao a renda usada como base)
    const mesAlvo = `${hoje.getFullYear()}-${String(hoje.getMonth() + 1).padStart(2, "0")}`;

    // Mes base da renda = mes atual - 2
    const baseDate = new Date(hoje.getFullYear(), hoje.getMonth() - 2, 1);
    const mesBaseIni = baseDate.toISOString().slice(0, 10);
    const mesBaseFim = new Date(baseDate.getFullYear(), baseDate.getMonth() + 1, 0)
      .toISOString().slice(0, 10);

    // 1. Listar todas as familias
    const { data: familias, error: errF } = await supabase
      .from("families")
      .select("id");
    if (errF) throw errF;

    const resultados: unknown[] = [];

    for (const fam of familias ?? []) {
      // 2. Somar receitas do mes base (M-2)
      const { data: receitas, error: errR } = await supabase
        .from("transactions")
        .select("amount")
        .eq("family_id", fam.id)
        .eq("type", "income")
        .gte("date", mesBaseIni)
        .lte("date", mesBaseFim);

      if (errR) throw errR;

      const rendaBase = (receitas ?? []).reduce(
        (acc, r) => acc + Number(r.amount), 0,
      );

      if (rendaBase <= 0) {
        resultados.push({ familia: fam.id, status: "SEM_RENDA_BASE", mesBase: mesBaseIni });
        continue;
      }

      // 3. Aplicar regra 50/30/20
      const necessidades = rendaBase * 0.50;
      const desejos      = rendaBase * 0.30;
      const investimento = rendaBase * 0.20;

      // 4. Inserir/atualizar monthly_budgets (upsert por family_id + month)
      const { error: errUp } = await supabase
        .from("monthly_budgets")
        .upsert({
          family_id: fam.id,
          month: mesAlvo,
          base_income: rendaBase,
          needs_amount: necessidades,
          wants_amount: desejos,
          savings_amount: investimento,
          source: "edge_function_OD",
        }, { onConflict: "family_id,month" });

      if (errUp) throw errUp;

      await logAudit(supabase, fam.id, "monthly_budget_generated", {
        mes_alvo: mesAlvo,
        mes_base: mesBaseIni,
        renda_base: rendaBase,
        regra: "50/30/20",
      });

      resultados.push({
        familia: fam.id,
        status: "OK",
        mesAlvo,
        rendaBase,
        necessidades, desejos, investimento,
      });
    }

    return new Response(
      JSON.stringify({ ok: true, mesAlvo, processadas: resultados.length, resultados }),
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
