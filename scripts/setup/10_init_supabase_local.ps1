$ErrorActionPreference = "Continue"
$ProjectRoot = "C:\APP_Finanças"
$SupabaseDir = "$ProjectRoot\supabase"
$LogDir = "$ProjectRoot\logs"
$LogFile = "$LogDir\10_init_supabase_local.log"

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value "[$timestamp] $Message" -Encoding UTF8
}

Clear-Host
Write-Log "===========================================================" "Cyan"
Write-Log "  SCRIPT 10 - INIT SUPABASE LOCAL" "Cyan"
Write-Log "===========================================================" "Cyan"
Write-Log ""

# 1. Verificar Supabase CLI
Write-Log "[1/6] Verificando Supabase CLI..." "Yellow"
try {
    $supabaseVersion = & supabase --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Log "  [OK] Supabase CLI: $supabaseVersion" "Green"
    } else {
        Write-Log "  [ERRO] Supabase CLI nao funciona" "Red"
        exit 1
    }
} catch {
    Write-Log "  [ERRO] Supabase CLI nao encontrado" "Red"
    exit 1
}
Write-Log ""

# 2. Verificar/criar pasta supabase
Write-Log "[2/6] Preparando pasta supabase..." "Yellow"
if (Test-Path $SupabaseDir) {
    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupName = "supabase.backup.$stamp"
    Write-Log "  [AVISO] Pasta supabase ja existe - fazendo backup" "Yellow"
    Rename-Item -Path $SupabaseDir -NewName $backupName -Force
    Write-Log "  [OK] Backup: $backupName" "Green"
} else {
    Write-Log "  [OK] Pasta nao existe, sera criada" "Green"
}
Write-Log ""

# 3. Rodar supabase init
Write-Log "[3/6] Rodando supabase init..." "Yellow"
Set-Location $ProjectRoot
$saida = & supabase init 2>&1
$exitCode = $LASTEXITCODE
$saida | ForEach-Object {
    Write-Host "    $_" -ForegroundColor Gray
    Add-Content -Path $LogFile -Value "    $_" -Encoding UTF8
}
if ($exitCode -ne 0) {
    Write-Log "  [ERRO] supabase init falhou (exit: $exitCode)" "Red"
    exit 1
}
Write-Log "  [OK] Estrutura Supabase criada" "Green"
Write-Log ""

# 4. Pasta migrations
Write-Log "[4/6] Verificando pasta migrations..." "Yellow"
$migrationsDir = "$SupabaseDir\migrations"
if (-not (Test-Path $migrationsDir)) {
    New-Item -ItemType Directory -Path $migrationsDir -Force | Out-Null
    Write-Log "  [OK] Pasta migrations criada" "Green"
} else {
    Write-Log "  [OK] Pasta migrations ja existe" "Green"
}
$gitkeep = Join-Path $migrationsDir ".gitkeep"
if (-not (Test-Path $gitkeep)) {
    New-Item -ItemType File -Path $gitkeep -Force | Out-Null
}
Write-Log ""

# 5. Criar README simples
Write-Log "[5/6] Criando README do Supabase..." "Yellow"
$readmePath = "$SupabaseDir\README.md"
$readmeLinhas = @()
$readmeLinhas += "# Supabase - DinDinVani&Nani"
$readmeLinhas += ""
$readmeLinhas += "Estrutura local do Supabase para o projeto."
$readmeLinhas += ""
$readmeLinhas += "## Comandos uteis"
$readmeLinhas += ""
$readmeLinhas += "- supabase login         (primeira vez)"
$readmeLinhas += "- supabase link --project-ref REF"
$readmeLinhas += "- supabase db push       (aplica migrations no Cloud)"
$readmeLinhas += "- supabase status        (status do projeto)"
$readmeLinhas += ""
$readmeLinhas += "## Workflow"
$readmeLinhas += ""
$readmeLinhas += "1. Scripts 12-16 vao gerar SQL em migrations/"
$readmeLinhas += "2. Crie projeto gratuito em https://supabase.com"
$readmeLinhas += "3. Rode supabase link e supabase db push"
$readmeLinhas += ""
$readmeLinhas += "Usamos apenas Supabase Cloud (gratuito). Sem Docker local."
$readmeLinhas | Out-File -FilePath $readmePath -Encoding UTF8
Write-Log "  [OK] README.md criado" "Green"
Write-Log ""

# 6. Verificar estrutura final
Write-Log "[6/6] Verificando estrutura final..." "Yellow"
$arquivos = @("supabase\config.toml", "supabase\migrations", "supabase\README.md")
$okCount = 0
foreach ($arq in $arquivos) {
    $caminho = Join-Path $ProjectRoot $arq
    if (Test-Path $caminho) {
        Write-Log "  [OK] $arq" "Green"
        $okCount++
    } else {
        Write-Log "  [FALTA] $arq" "Red"
    }
}
Write-Log ""
Write-Log "===========================================================" "Cyan"
if ($okCount -eq $arquivos.Count) {
    Write-Log "  SCRIPT 10 CONCLUIDO COM SUCESSO!" "Green"
    Write-Log "===========================================================" "Green"
    Write-Log ""
    Write-Log "  Proximo: Script 11 - create_project_structure" "Yellow"
} else {
    Write-Log "  [AVISO] Faltam arquivos ($okCount/$($arquivos.Count))" "Yellow"
    Write-Log "===========================================================" "Yellow"
}
Write-Log ""
Set-Location $ProjectRoot
