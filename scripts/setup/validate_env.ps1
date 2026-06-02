# ============================================================
# Script: validate_env.ps1
# Projeto: DinDinVani&Nani
# ============================================================

$ProjectRoot = "C:\APP_Finanças"
$AppDir      = Join-Path $ProjectRoot "app"
$EnvFile     = Join-Path $AppDir ".env"
$GitIgnore   = Join-Path $ProjectRoot ".gitignore"
$PubspecFile = Join-Path $AppDir "pubspec.yaml"
$LogDir      = Join-Path $ProjectRoot "logs"
$LogFile     = Join-Path $LogDir "validate_env.log"

$RequiredVars = @("SUPABASE_URL","SUPABASE_PUBLISHABLE_KEY","SUPABASE_SECRET_KEY")

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message,[string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    switch ($Level) {
        "OK"    { Write-Host $line -ForegroundColor Green }
        "ERRO"  { Write-Host $line -ForegroundColor Red }
        "AVISO" { Write-Host $line -ForegroundColor Yellow }
        default { Write-Host $line -ForegroundColor Cyan }
    }
}

Clear-Host
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "  DinDinVani&Nani - Validacao do .env" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Log "Iniciando validacao do .env"

$ErrosEncontrados = 0
$AvisosEncontrados = 0

Write-Host "`n[1/5] Verificando existencia do .env..." -ForegroundColor White
if (Test-Path $EnvFile) {
    Write-Log ".env encontrado em: $EnvFile" "OK"
} else {
    Write-Log ".env NAO encontrado em: $EnvFile" "ERRO"
    Write-Host "`nPressione qualquer tecla para fechar..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "`n[2/5] Verificando variaveis obrigatorias..." -ForegroundColor White
$envContent = Get-Content $EnvFile -Encoding UTF8
$envVars = @{}
foreach ($line in $envContent) {
    $trimmed = $line.Trim()
    if ($trimmed -and -not $trimmed.StartsWith("#") -and $trimmed.Contains("=")) {
        $parts = $trimmed -split "=", 2
        $envVars[$parts[0].Trim()] = $parts[1].Trim()
    }
}
foreach ($var in $RequiredVars) {
    if ($envVars.ContainsKey($var)) {
        if ([string]::IsNullOrWhiteSpace($envVars[$var])) {
            Write-Log "$var existe mas esta VAZIA" "ERRO"
            $ErrosEncontrados++
        } else {
            Write-Log "$var OK (tamanho: $($envVars[$var].Length) caracteres)" "OK"
        }
    } else {
        Write-Log "$var FALTANDO no .env" "ERRO"
        $ErrosEncontrados++
    }
}
if ($envVars.ContainsKey("SUPABASE_URL") -and -not $envVars["SUPABASE_URL"].StartsWith("https://")) {
    Write-Log "SUPABASE_URL nao comeca com https:// - verifique!" "AVISO"
    $AvisosEncontrados++
}

Write-Host "`n[3/5] Verificando .gitignore..." -ForegroundColor White
if (-not (Test-Path $GitIgnore)) {
    New-Item -ItemType File -Path $GitIgnore -Force | Out-Null
    Write-Log ".gitignore criado" "OK"
}
$gitignoreContent = Get-Content $GitIgnore -Encoding UTF8 -ErrorAction SilentlyContinue
foreach ($entrada in @(".env",".env.local","*.env")) {
    if ($gitignoreContent -notcontains $entrada) {
        Add-Content -Path $GitIgnore -Value $entrada -Encoding UTF8
        Write-Log "Adicionado '$entrada' ao .gitignore" "OK"
    } else {
        Write-Log "'$entrada' ja esta no .gitignore" "OK"
    }
}

Write-Host "`n[4/5] Verificando pubspec.yaml..." -ForegroundColor White
if (Test-Path $PubspecFile) {
    $pubspecContent = Get-Content $PubspecFile -Encoding UTF8 -Raw
    if ($pubspecContent -match "(?m)^\s*-\s*\.env\s*$") {
        Write-Log ".env declarado como asset no pubspec.yaml" "OK"
    } else {
        Write-Log ".env NAO declarado como asset (sera feito no script 09)" "AVISO"
        $AvisosEncontrados++
    }
    if ($pubspecContent -match "flutter_dotenv") {
        Write-Log "flutter_dotenv encontrado no pubspec.yaml" "OK"
    } else {
        Write-Log "flutter_dotenv ainda nao adicionado (sera feito no script 09)" "AVISO"
        $AvisosEncontrados++
    }
} else {
    Write-Log "pubspec.yaml nao existe (sera criado no script 08)" "AVISO"
    $AvisosEncontrados++
}

Write-Host "`n[5/5] Resumo da validacao" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Magenta
Write-Log "Erros encontrados:  $ErrosEncontrados" $(if ($ErrosEncontrados -gt 0) { "ERRO" } else { "OK" })
Write-Log "Avisos encontrados: $AvisosEncontrados" $(if ($AvisosEncontrados -gt 0) { "AVISO" } else { "OK" })
Write-Host "============================================================" -ForegroundColor Magenta

if ($ErrosEncontrados -eq 0) {
    Write-Host "`n[SUCESSO] .env validado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "`n[FALHA] Corrija os erros acima antes de avancar." -ForegroundColor Red
}
Write-Host "Log salvo em: $LogFile" -ForegroundColor Gray
Write-Host "`nPressione qualquer tecla para fechar..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
