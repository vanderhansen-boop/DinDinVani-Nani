-- ============================================================
-- 16_schedule_edge_functions.sql
-- Agendamento das Edge Functions via pg_cron + pg_net
-- ============================================================
-- PRE-REQUISITO: no painel Supabase -> Database -> Extensions
-- ative: pg_cron e pg_net
--
-- ANTES DE RODAR: substitua os placeholders:
--   <PROJECT_REF>           -> ref do projeto (ex: abcd1234efgh)
--   <SERVICE_ROLE_KEY>      -> chave service_role do projeto
-- ============================================================

-- Helper: invoca uma edge function via HTTP
CREATE OR REPLACE FUNCTION public.invoke_edge_function(fn_name text)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE req_id bigint; BEGIN SELECT net.http_post( url := 'https://<PROJECT_REF>.supabase.co/functions/v1/' || fn_name, headers := jsonb_build_object( 'Content-Type', 'application/json', 'Authorization', 'Bearer <SERVICE_ROLE_KEY>' ), body := '{}'::jsonb ) INTO req_id; RETURN req_id; END;
$$;

-- Remove jobs antigos com mesmo nome (idempotente)
SELECT cron.unschedule(jobname) FROM cron.job
WHERE jobname IN (
  'job_pay_invoice_daily',
  'job_pay_cpi_daily',
  'job_generate_budget_monthly',
  'job_recalculate_score_daily'
);

-- 1. Pagar faturas vencendo: todo dia as 06:00 UTC (~03:00 BRT)
SELECT cron.schedule(
  'job_pay_invoice_daily',
  '0 6 * * *',
  $$SELECT public.invoke_edge_function('pay_invoice_on_due_date');$$
);

-- 2. Liberar parcelas CPI: todo dia as 06:10 UTC
SELECT cron.schedule(
  'job_pay_cpi_daily',
  '10 6 * * *',
  $$SELECT public.invoke_edge_function('pay_cpi_installment');$$
);

-- 3. Gerar orcamento mensal: dia 1 as 05:00 UTC
SELECT cron.schedule(
  'job_generate_budget_monthly',
  '0 5 1 * *',
  $$SELECT public.invoke_edge_function('generate_monthly_budget');$$
);

-- 4. Recalcular score: todo dia as 07:00 UTC
SELECT cron.schedule(
  'job_recalculate_score_daily',
  '0 7 * * *',
  $$SELECT public.invoke_edge_function('recalculate_score');$$
);

-- Verificacao
SELECT jobid, schedule, jobname FROM cron.job ORDER BY jobname;
