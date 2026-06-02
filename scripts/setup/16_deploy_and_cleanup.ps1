<#
 Script: 16_deploy_and_cleanup.ps1 (v2 - sem Docker, com --use-api)
 Projeto: DinDinVani&Nani
#>

$ErrorActionPreference = "Continue"
$BASE        = "Z:\AppFinancas"
$LOG_DIR     = "$BASE\logs"
$LOG_FILE    = "$LOG_DIR\16_deploy_and_cleanup.log"
$MEMORIA     = "$BASE\MEMORIA_PROJETO.md"
$PROJECT_REF = "xzbfdklyvgqlyowrlhfb"

$C_LIMPAR = @(
    "C:\APP_Finanças",
    "C:\APP_Financas_OLD_ate_script12"
)

$FUNCTIONS = @(
    "generate_monthly_budget",
    "pay_cpi_installment",
    "pay_invoice_on_due_date",
    "recalculate_score"
)

if (-not (Test-Path $LOG_DIR)) { New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null }
"" | Out-File $LOG_FILE -Encoding utf8

function Log {
    param([string]$msg, [string]$color = "White")
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$stamp] $msg"
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $LOG_FILE -Value $line -Encoding utf8
}

Log "================================================================" "Cyan"
Log " SCRIPT 16 v2 - Deploy via API (sem Docker) + Limpeza + Memoria" "Cyan"
Log "================================================================" "Cyan"

Set-Location $BASE

# ETAPA 1 - Validar
Log "`n--- ETAPA 1: Validar pre-requisitos ---" "Yellow"
$v = (supabase --version 2>&1) | Out-String
Log "Supabase CLI: $($v.Trim())" "Green"

foreach ($f in $FUNCTIONS) {
    $path = "$BASE\supabase\functions\$f\index.ts"
    if (Test-Path $path) {
        Log "OK: $f\index.ts" "Green"
    } else {
        Log "ERRO: $path nao existe" "Red"
        exit 1
    }
}

# ETAPA 2 - Deploy com --use-api (SEM DOCKER)
Log "`n--- ETAPA 2: Deploy via API (sem Docker) ---" "Yellow"

$deployOK = @()
$deployFAIL = @()

foreach ($f in $FUNCTIONS) {
    Log "Deploying: $f (via --use-api)..." "Cyan"
    $out = & supabase functions deploy $f --use-api --no-verify-jwt --project-ref $PROJECT_REF 2>&1 | Out-String
    Add-Content -Path $LOG_FILE -Value $out -Encoding utf8

    if ($LASTEXITCODE -eq 0) {
        Log "  OK: $f deployada via API" "Green"
        $deployOK += $f
    } else {
        Log "  FALHA: $f (exit $LASTEXITCODE)" "Red"
        Log "  Saida: $($out.Trim())" "Red"
        $deployFAIL += $f
    }
}

Log "`nResumo deploy: $($deployOK.Count) OK / $($deployFAIL.Count) FALHA" "Cyan"

# ETAPA 3 - Validar
Log "`n--- ETAPA 3: Listar funcoes no Supabase ---" "Yellow"
$listOutput = (& supabase functions list 2>&1) | Out-String
Add-Content -Path $LOG_FILE -Value $listOutput -Encoding utf8
Write-Host $listOutput

$deployedCount = 0
foreach ($f in $FUNCTIONS) {
    if ($listOutput -match $f) {
        Log "Confirmada no Supabase: $f" "Green"
        $deployedCount++
    } else {
        Log "AUSENTE: $f" "Red"
    }
}

# ETAPA 4 - Limpar C: (so se TODAS funcoes OK)
Log "`n--- ETAPA 4: Limpeza C: ---" "Yellow"

if ($deployedCount -eq 4) {
    $liberadoMB = 0
    foreach ($pasta in $C_LIMPAR) {
        if (Test-Path $pasta) {
            try {
                $tam = (Get-ChildItem $pasta -Recurse -File -ErrorAction SilentlyContinue |
                        Measure-Object -Property Length -Sum).Sum
                $tamMB = [math]::Round($tam / 1MB, 2)
                Log "Removendo $pasta ($tamMB MB)..." "Cyan"
                Remove-Item $pasta -Recurse -Force -ErrorAction Stop
                Log "  OK removido" "Green"
                $liberadoMB += $tamMB
            } catch {
                Log "  ERRO ao remover: $_" "Red"
            }
        } else {
            Log "Ja nao existe: $pasta" "Gray"
        }
    }
    Log "Liberado: $liberadoMB MB" "Green"
} else {
    Log "PULANDO limpeza C: (deploy incompleto $deployedCount/4)" "Yellow"
    Log "Rode o script novamente apos resolver o deploy" "Yellow"
}

# ETAPA 5 - Memoria (so se TODAS funcoes OK)
Log "`n--- ETAPA 5: Atualizar MEMORIA_PROJETO.md ---" "Yellow"

if ($deployedCount -eq 4 -and (Test-Path $MEMORIA)) {
    Copy-Item $MEMORIA "$MEMORIA.bak_20260601" -Force
    $content = Get-Content $MEMORIA -Raw -Encoding utf8

    $old16 = "- [ ] 16 — create_edge_functions"
    $new16 = "- [x] 16 — create_edge_functions  ✅ deploy 01/06/2026 (via --use-api)"
    if ($content -match [regex]::Escape($old16)) {
        $content = $content -replace [regex]::Escape($old16), $new16
        Log "Script 16 marcado [x]" "Green"
    }

    $marker = "## 📍 Caminho base e Migração"
    if ($content -notmatch [regex]::Escape($marker)) {
        $bloco = "`n`n$marker`n`n- **Caminho atual**: ``Z:\AppFinancas```n- **Caminho antigo**: ``C:\APP_Finanças`` (removido em 01/06/2026)`n- **Motivo**: liberar C: e isolar projeto`n`n### Histórico`n- 28/05/2026 — Projeto iniciado em C:`n- 30/05/2026 — Scripts 01–15b executados`n- 01/06/2026 — Migração Z: + deploy script 16 (sem Docker, via --use-api)`n`n### Supabase`n- Projeto: dindinvani (ref ``xzbfdklyvgqlyowrlhfb``)`n- Região: South America (São Paulo)`n- Edge Functions: 4 deployadas`n"
        $content = $content.TrimEnd() + $bloco
        Log "Seção de migração adicionada" "Green"
    }

    Set-Content -Path $MEMORIA -Value $content -Encoding utf8 -NoNewline
    Log "MEMORIA atualizada" "Green"
} else {
    Log "PULANDO memoria (deploy incompleto)" "Yellow"
}

# RESUMO
Log "`n================================================================" "Cyan"
Log " RESUMO FINAL" "Cyan"
Log "================================================================" "Cyan"
Log "Deploy OK: $($deployOK.Count) / 4"
Log "Confirmadas no Supabase: $deployedCount / 4"
Log "Log: $LOG_FILE"
Log "================================================================" "Cyan"
