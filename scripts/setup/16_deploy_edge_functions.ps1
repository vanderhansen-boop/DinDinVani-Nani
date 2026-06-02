# Deploy das Edge Functions no Supabase remoto
# Pre-requisitos:
#   1. supabase login  (uma vez)
#   2. supabase link --project-ref <PROJECT_REF>  (uma vez)
#   3. supabase secrets set --env-file .\supabase\.env.local

$ErrorActionPreference = "Stop"
Set-Location "C:\APP_Finanças"

$functions = @(
    "pay_invoice_on_due_date",
    "pay_cpi_installment",
    "generate_monthly_budget",
    "recalculate_score"
)

Write-Host "Deploy de Edge Functions iniciado..." -ForegroundColor Cyan

foreach ($fn in $functions) {
    Write-Host ""
    Write-Host "==> Deploy: $fn" -ForegroundColor Yellow
    supabase functions deploy $fn --no-verify-jwt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FALHA no deploy de $fn" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Deploy concluido com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximo passo: rode a migration de agendamento no SQL Editor:" -ForegroundColor Cyan
Write-Host "  supabase\migrations\16_schedule_edge_functions.sql" -ForegroundColor Gray
