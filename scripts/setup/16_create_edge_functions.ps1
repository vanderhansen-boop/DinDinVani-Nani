<#
================================================================================
 Script 16 — create_edge_functions.ps1
 Projeto: DinDinVani&Nani
 Objetivo: Criar 5 Edge Functions (Deno/TypeScript) para automação financeira
 Diretório fixo: C:\APP_Finanças
================================================================================
#>

# ============== CONFIG ==============
$ErrorActionPreference = "Stop"
$BASE        = "C:\APP_Finanças"
$PROJECT     = Join-Path $BASE "dindinvani_nani"
$FUNCS_DIR   = Join-Path $PROJECT "supabase\functions"
$LOGS_DIR    = Join-Path $BASE "logs"
$LOG_FILE    = Join-Path $LOGS_DIR "16_create_edge_functions.log"

# ============== HELPERS ==============
function Write-Log {
    param([string]$msg, [string]$level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$level] $msg"
    Write-Host $line
    Add-Content -Path $LOG_FILE -Value $line -Encoding UTF8
}

function Ensure-Dir {
    param([string]$path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Write-File {
    param([string]$path, [string]$content)
    $dir = Split-Path $path -Parent
    Ensure-Dir $dir
    Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
    Write-Log "Arquivo criado: $path"
}

# ============== START ==============
Ensure-Dir $LOGS_DIR
if (Test-Path $LOG_FILE) { Remove-Item $LOG_FILE -Force }

Write-Log "=========================================="
Write-Log "INÍCIO — Script 16: create_edge_functions"
Write-Log "=========================================="

# Verifica se projeto existe
if (-not (Test-Path $PROJECT)) {
    Write-Log "Projeto Flutter não encontrado em $PROJECT" "ERROR"
    exit 1
}
Ensure-Dir $FUNCS_DIR
Write-Log "Diretório base das functions: $FUNCS_DIR"

# ============================================================================
# 1) _shared/cors.ts  — Headers CORS reutilizáveis
# ============================================================================
$corsTs = @'
// Headers CORS padrão para todas as Edge Functions
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};
'@
Write-File (Join-Path $FUNCS_DIR "_shared\cors.ts") $corsTs

# ============================================================================
# 2) _shared/supabase.ts  — Cliente Supabase com Service Role
# ============================================================================
$supabaseTs = @'
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

export function getServiceClient() {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) {
    throw new Error("Variáveis SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY ausentes");
  }
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
'@
Write-File (Join-Path $FUNCS_DIR "_shared\supabase.ts") $supabaseTs

# ============================================================================
# 3) _shared/audit.ts  — Logger em audit_log
# ============================================================================
$auditTs = @'
import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

export async function audit(
  supabase: SupabaseClient,
  action: string,
  payload: Record<string, unknown>,
  status: "success" | "error" = "success",
) {
  try {
    await supabase.from("audit_log").insert({
      action,
      payload,
      status,
      source: "edge_function",
      created_at: new Date().toISOString(),
    });
  } catch (e) {
    console.error("Falha ao gravar audit_log:", e);
  }
}
'@
Write-File (Join-Path $FUNCS_DIR "_shared\audit.ts") $auditTs

# ============================================================================
# FUNCTION 1 — pay-invoice-automatic
# Paga a fatura do cartão no vencimento usando saldo da CF
# ============================================================================
$payInvoice = @'
// Edge Function: pay-invoice-automatic
// Paga automaticamente faturas vencendo hoje, debitando da Caixinha de Fatura (CF)
// Idempotente: não paga 2x a mesma fatura

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase.ts";
import { audit } from "../_shared/audit.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = getServiceClient();
  const today = new Date().toISOString().slice(0, 10);
  const results: unknown[] = [];

  try {
    // Busca faturas vencendo hoje e ainda não pagas
    const { data: invoices, error } = await supabase
      .from("invoices")
      .select("id, family_id, credit_card_id, total_amount, due_date, status")
      .eq("due_date", today)
      .neq("status", "paid");

    if (error) throw error;

    for (const inv of invoices ?? []) {
      // Busca a CF (piggy_bank tipo CF) deste cartão
      const { data: cf } = await supabase
        .from("piggy_banks")
        .select("id, current_balance")
        .eq("family_id", inv.family_id)
        .eq("type", "CF")
        .eq("credit_card_id", inv.credit_card_id)
        .maybeSingle();

      if (!cf) {
        results.push({ invoice_id: inv.id, status: "skipped", reason: "CF não encontrada" });
        continue;
      }

      if (Number(cf.current_balance) < Number(inv.total_amount)) {
        results.push({
          invoice_id: inv.id,
          status: "insufficient_funds",
          cf_balance: cf.current_balance,
          required: inv.total_amount,
        });
        await audit(supabase, "pay_invoice_failed", { invoice_id: inv.id, reason: "saldo insuficiente CF" }, "error");
        continue;
      }

      // Debita CF e marca fatura como paga (transação manual via 2 updates)
      const newBalance = Number(cf.current_balance) - Number(inv.total_amount);

      const { error: e1 } = await supabase
        .from("piggy_banks")
        .update({ current_balance: newBalance })
        .eq("id", cf.id);
      if (e1) throw e1;

      const { error: e2 } = await supabase
        .from("invoices")
        .update({ status: "paid", paid_at: new Date().toISOString() })
        .eq("id", inv.id);
      if (e2) throw e2;

      await audit(supabase, "pay_invoice_success", {
        invoice_id: inv.id,
        amount: inv.total_amount,
        cf_id: cf.id,
      });

      results.push({ invoice_id: inv.id, status: "paid", amount: inv.total_amount });
    }

    return new Response(
      JSON.stringify({ ok: true, date: today, processed: results.length, results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    await audit(supabase, "pay_invoice_automatic_error", { error: String(err) }, "error");
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
'@
Write-File (Join-Path $FUNCS_DIR "pay-invoice-automatic\index.ts") $payInvoice

# ============================================================================
# FUNCTION 2 — pay-cpi-installment
# Debita a parcela mensal da CPI e libera o valor para a CF
# ============================================================================
$payCpi = @'
// Edge Function: pay-cpi-installment
// Processa parcelas CPI vencendo hoje:
// 1. Debita o valor da reserva CPI (piggy_bank_reservations)
// 2. Credita esse valor na CF do cartão correspondente
// 3. Registra em cpi_installment_payments
// Idempotente via cpi_installment_payments (unique: reservation_id + installment_number)

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase.ts";
import { audit } from "../_shared/audit.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = getServiceClient();
  const today = new Date().toISOString().slice(0, 10);
  const results: unknown[] = [];

  try {
    // Busca parcelas CPI com due_date == hoje e ainda não pagas
    const { data: pending, error } = await supabase
      .from("piggy_bank_reservations")
      .select("id, family_id, piggy_bank_id, credit_card_id, installment_amount, total_installments, paid_installments, next_due_date")
      .eq("type", "CPI")
      .eq("next_due_date", today)
      .lt("paid_installments", "total_installments");

    if (error) throw error;

    for (const res of pending ?? []) {
      const nextInstallment = (res.paid_installments ?? 0) + 1;

      // Idempotência: checa se essa parcela já foi paga
      const { data: already } = await supabase
        .from("cpi_installment_payments")
        .select("id")
        .eq("reservation_id", res.id)
        .eq("installment_number", nextInstallment)
        .maybeSingle();

      if (already) {
        results.push({ reservation_id: res.id, status: "already_paid", installment: nextInstallment });
        continue;
      }

      // Busca CF do cartão
      const { data: cf } = await supabase
        .from("piggy_banks")
        .select("id, current_balance")
        .eq("family_id", res.family_id)
        .eq("type", "CF")
        .eq("credit_card_id", res.credit_card_id)
        .maybeSingle();

      if (!cf) {
        results.push({ reservation_id: res.id, status: "skipped", reason: "CF não encontrada" });
        continue;
      }

      // Credita CF com o valor da parcela (saiu da CPI, vai pra CF pagar fatura)
      const newCfBalance = Number(cf.current_balance) + Number(res.installment_amount);
      const { error: e1 } = await supabase
        .from("piggy_banks")
        .update({ current_balance: newCfBalance })
        .eq("id", cf.id);
      if (e1) throw e1;

      // Atualiza contagem de parcelas pagas e próxima data
      const next = new Date(today);
      next.setMonth(next.getMonth() + 1);
      const nextDate = next.toISOString().slice(0, 10);

      const { error: e2 } = await supabase
        .from("piggy_bank_reservations")
        .update({
          paid_installments: nextInstallment,
          next_due_date: nextInstallment >= res.total_installments ? null : nextDate,
          status: nextInstallment >= res.total_installments ? "completed" : "active",
        })
        .eq("id", res.id);
      if (e2) throw e2;

      // Registra pagamento
      const { error: e3 } = await supabase.from("cpi_installment_payments").insert({
        reservation_id: res.id,
        installment_number: nextInstallment,
        amount: res.installment_amount,
        paid_at: new Date().toISOString(),
        cf_piggy_bank_id: cf.id,
      });
      if (e3) throw e3;

      await audit(supabase, "pay_cpi_installment_success", {
        reservation_id: res.id,
        installment: nextInstallment,
        amount: res.installment_amount,
      });

      results.push({
        reservation_id: res.id,
        status: "paid",
        installment: nextInstallment,
        of: res.total_installments,
        amount: res.installment_amount,
      });
    }

    return new Response(
      JSON.stringify({ ok: true, date: today, processed: results.length, results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    await audit(supabase, "pay_cpi_installment_error", { error: String(err) }, "error");
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
'@
Write-File (Join-Path $FUNCS_DIR "pay-cpi-installment\index.ts") $payCpi

# ============================================================================
# FUNCTION 3 — apply-monthly-budget
# Aplica o Orçamento Defasado: renda do mês M → orçamento de M+2
# ============================================================================
$applyBudget = @'
// Edge Function: apply-monthly-budget
// Filosofia OD (Orçamento Defasado):
// - Renda recebida no mês M define o orçamento disponível no mês M+2
// - Executa no dia 1 de cada mês: lê renda total de (mês_atual - 2) e cria monthly_budgets do mês atual
// Idempotente: 1 registro por (family_id, year, month)

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase.ts";
import { audit } from "../_shared/audit.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = getServiceClient();
  const now = new Date();
  const currentYear = now.getUTCFullYear();
  const currentMonth = now.getUTCMonth() + 1; // 1-12

  // Mês fonte da renda = mês atual - 2
  const sourceDate = new Date(Date.UTC(currentYear, currentMonth - 1 - 2, 1));
  const sourceYear = sourceDate.getUTCFullYear();
  const sourceMonth = sourceDate.getUTCMonth() + 1;
  const sourceStart = `${sourceYear}-${String(sourceMonth).padStart(2, "0")}-01`;
  const sourceEnd = new Date(Date.UTC(sourceYear, sourceMonth, 1)).toISOString().slice(0, 10);

  const results: unknown[] = [];

  try {
    const { data: families, error } = await supabase.from("families").select("id");
    if (error) throw error;

    for (const fam of families ?? []) {
      // Verifica se já existe orçamento do mês atual
      const { data: existing } = await supabase
        .from("monthly_budgets")
        .select("id")
        .eq("family_id", fam.id)
        .eq("year", currentYear)
        .eq("month", currentMonth)
        .maybeSingle();

      if (existing) {
        results.push({ family_id: fam.id, status: "already_exists" });
        continue;
      }

      // Soma renda (transactions type='income') do mês fonte
      const { data: incomes, error: ie } = await supabase
        .from("transactions")
        .select("amount")
        .eq("family_id", fam.id)
        .eq("type", "income")
        .gte("date", sourceStart)
        .lt("date", sourceEnd);
      if (ie) throw ie;

      const totalIncome = (incomes ?? []).reduce((s, t) => s + Number(t.amount), 0);

      // Cria monthly_budget aplicando 50/30/20
      const { error: be } = await supabase.from("monthly_budgets").insert({
        family_id: fam.id,
        year: currentYear,
        month: currentMonth,
        total_income: totalIncome,
        essentials_limit: totalIncome * 0.5,
        lifestyle_limit: totalIncome * 0.3,
        goals_limit: totalIncome * 0.2,
        source_year: sourceYear,
        source_month: sourceMonth,
        created_at: new Date().toISOString(),
      });
      if (be) throw be;

      await audit(supabase, "apply_monthly_budget_success", {
        family_id: fam.id,
        year: currentYear,
        month: currentMonth,
        source: `${sourceYear}-${sourceMonth}`,
        total_income: totalIncome,
      });

      results.push({
        family_id: fam.id,
        status: "created",
        total_income: totalIncome,
        source: `${sourceYear}-${sourceMonth}`,
      });
    }

    return new Response(
      JSON.stringify({ ok: true, year: currentYear, month: currentMonth, results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    await audit(supabase, "apply_monthly_budget_error", { error: String(err) }, "error");
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
'@
Write-File (Join-Path $FUNCS_DIR "apply-monthly-budget\index.ts") $applyBudget

# ============================================================================
# FUNCTION 4 — process-recurring-transactions
# Gera transações recorrentes do dia (salários, aluguéis, assinaturas)
# ============================================================================
$recurring = @'
// Edge Function: process-recurring-transactions
// Gera transações automáticas a partir de recurring_transactions cuja next_execution == hoje
// Atualiza next_execution conforme frequency (monthly, weekly, yearly)

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { getServiceClient } from "../_shared/supabase.ts";
import { audit } from "../_shared/audit.ts";

function addPeriod(dateStr: string, frequency: string): string {
  const d = new Date(dateStr);
  switch (frequency) {
    case "weekly":
      d.setDate(d.getDate() + 7);
      break;
    case "biweekly":
      d.setDate(d.getDate() + 14);
      break;
    case "yearly":
      d.setFullYear(d.getFullYear() + 1);
      break;
    case "monthly":
    default:
      d.setMonth(d.getMonth() + 1);
  }
  return d.toISOString().slice(0, 10);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = getServiceClient();
  const today = new Date().toISOString().slice(0, 10);
  const results: unknown[] = [];

  try {
    const { data: pending, error } = await supabase
      .from("recurring_transactions")
      .select("*")
      .eq("active", true)
      .lte("next_execution", today);

    if (error) throw error;

    for (const rt of pending ?? []) {
      // Cria a transação
      const { error: te } = await supabase.from("transactions").insert({
        family_id: rt.family_id,
        user_id: rt.user_id,
        account_id: rt.account_id,
        category_id: rt.category_id,
        type: rt.type,
        amount: rt.amount,
        description: rt.description,
        date: today,
        recurring_id: rt.id,
        created_at: new Date().toISOString(),
      });
      if (te) throw te;

      // Atualiza next_execution
      const next = addPeriod(today, rt.frequency);
      const { error: ue } = await supabase
        .from("recurring_transactions")
        .update({ next_execution: next, last_execution: today })
        .eq("id", rt.id);
      if (ue) throw ue;

      await audit(supabase, "recurring_transaction_processed", {
        recurring_id: rt.id,
        amount: rt.amount,
        type: rt.type,
      });

      results.push({ id: rt.id, status: "created", amount: rt.amount, next });
    }

    return new Response(
      JSON.stringify({ ok: true, date: today, processed: results.length, results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error(err);
    await audit(supabase, "recurring_transactions_error", { error: String(err) }, "error");
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
'@
Write-File (Join-Path $FUNCS_DIR "process-recurring-transactions\index.ts") $recurring

# ============================================================================
# FUNCTION 5 — daily-cron
# Maestro: roda 1x/dia e chama as outras 4 functions
# ============================================================================
$dailyCron = @'
// Edge Function: daily-cron
// Função maestro que dispara as automações diárias:
// 1. process-recurring-transactions (todo dia)
// 2. pay-cpi-installment (todo dia, filtra por due_date)
// 3. pay-invoice-automatic (todo dia, filtra por due_date)
// 4. apply-monthly-budget (apenas dia 1 de cada mês)

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { audit } from "../_shared/audit.ts";
import { getServiceClient } from "../_shared/supabase.ts";

async function invoke(name: string): Promise<unknown> {
  const url = `${Deno.env.get("SUPABASE_URL")}/functions/v1/${name}`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
    body: JSON.stringify({ source: "daily-cron" }),
  });
  return await res.json();
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = getServiceClient();
  const today = new Date();
  const isFirstOfMonth = today.getUTCDate() === 1;
  const out: Record<string, unknown> = {};

  try {
    out.recurring = await invoke("process-recurring-transactions");
    out.cpi = await invoke("pay-cpi-installment");
    out.invoices = await invoke("pay-invoice-automatic");

    if (isFirstOfMonth) {
      out.budget = await invoke("apply-monthly-budget");
    } else {
      out.budget = { skipped: "not day 1" };
    }

    await audit(supabase, "daily_cron_success", out);

    return new Response(JSON.stringify({ ok: true, date: today.toISOString(), results: out }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error(err);
    await audit(supabase, "daily_cron_error", { error: String(err) }, "error");
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
'@
Write-File (Join-Path $FUNCS_DIR "daily-cron\index.ts") $dailyCron

# ============================================================================
# .env.example  — Variáveis de ambiente necessárias
# ============================================================================
$envExample = @'
# ===========================================
# Edge Functions — DinDinVani&Nani
# ===========================================
# Copie este arquivo para .env e preencha com suas chaves reais
# NUNCA commite o arquivo .env no Git

# URL do seu projeto Supabase (pega em: Project Settings > API)
SUPABASE_URL=https://SEU-PROJETO.supabase.co

# Service Role Key (NÃO use anon key aqui — precisa de privilégios elevados)
# Pega em: Project Settings > API > service_role (secret)
SUPABASE_SERVICE_ROLE_KEY=eyJxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Opcional: timezone para logs (default: UTC)
TZ=America/Sao_Paulo
'@
Write-File (Join-Path $FUNCS_DIR ".env.example") $envExample

# ============================================================================
# README.md  — Guia de deploy (versao limpa, sem caracteres especiais)
# ============================================================================
$readme = @'
# Edge Functions - DinDinVani e Nani

Automacao financeira do app, rodando em Supabase Edge Functions (Deno + TypeScript).

---

## Functions

| Nome | Disparo | O que faz |
|------|---------|-----------|
| pay-invoice-automatic | Diario | Paga faturas vencendo hoje usando saldo da CF |
| pay-cpi-installment | Diario | Debita parcela CPI e credita CF para pagar fatura |
| apply-monthly-budget | Mensal (dia 1) | Aplica Orcamento Defasado (renda M para orcamento M+2) |
| process-recurring-transactions | Diario | Gera transacoes recorrentes do dia |
| daily-cron | Diario (1x) | Maestro: chama todas as outras na ordem certa |

---

## Deploy

### 1. Configurar variaveis de ambiente

    cd C:\APP_Financas\dindinvani_nani
    cp supabase/functions/.env.example supabase/functions/.env
    (edite .env com suas chaves reais)

### 2. Login no Supabase

    supabase login
    supabase link --project-ref SEU-PROJECT-REF

### 3. Definir secrets no Supabase

    supabase secrets set SUPABASE_URL=https://SEU-PROJETO.supabase.co
    supabase secrets set SUPABASE_SERVICE_ROLE_KEY=eyJxxx...

### 4. Deploy de cada function

    supabase functions deploy pay-invoice-automatic
    supabase functions deploy pay-cpi-installment
    supabase functions deploy apply-monthly-budget
    supabase functions deploy process-recurring-transactions
    supabase functions deploy daily-cron

Ou todas de uma vez:

    supabase functions deploy --all

### 5. Agendar cron job

No Supabase Dashboard, va em Database > Cron Jobs e crie um job que
faca POST em /functions/v1/daily-cron todo dia as 06:00 UTC (03:00 BRT),
usando o Service Role Key no header Authorization.

---

## Testar localmente

    supabase functions serve daily-cron --env-file supabase/functions/.env

Em outro terminal, faca POST para http://localhost:54321/functions/v1/daily-cron
passando o header Authorization com Bearer SUA_ANON_KEY.

---

## Filosofia financeira respeitada

- OD  -> apply-monthly-budget usa renda de M-2 para orcamento de M
- CF  -> pay-invoice-automatic debita CF para pagar fatura
- CPI -> pay-cpi-installment move da CPI para a CF mensalmente
- Regra de ouro -> Idempotencia em todas: nenhuma despesa eh somada 2x

---

## Logs

Todas as execucoes gravam em audit_log com:
- action: nome do evento
- payload: dados detalhados
- status: success ou error
- source: edge_function
'@
Write-File (Join-Path $FUNCS_DIR "README.md") $readme
