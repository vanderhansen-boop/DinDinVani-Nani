<#
.SYNOPSIS
    Script 08 - Cria projeto Flutter dindinvani_nani
#>

$ErrorActionPreference = "Continue"
$ProjectRoot = "C:\APP_Finanças"
$AppDir = "$ProjectRoot\app"
$LogDir = "$ProjectRoot\logs"
$LogFile = "$LogDir\08_create_flutter_project.log"

$AppName = "dindinvani_nani"
$Organization = "com.dindinvaninani"
$Description = "App financeiro para casal Vani e Nani"

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
Write-Log "  SCRIPT 08 - CREATE FLUTTER PROJECT" "Cyan"
Write-Log "===========================================================" "Cyan"
Write-Log ""
Write-Log "  Nome: $AppName" "White"
Write-Log "  Org: $Organization" "White"
Write-Log "  Local: $AppDir" "White"
Write-Log "  Plataformas: Android, iOS, Web" "White"
Write-Log ""

Write-Log "[1/5] Verificando Flutter..." "Yellow"
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Log "  [OK] $flutterVersion" "Green"
} catch {
    Write-Log "  [ERRO] Flutter nao encontrado!" "Red"
    exit 1
}
Write-Log ""

Write-Log "[2/5] Verificando se projeto ja existe..." "Yellow"
if (Test-Path $AppDir) {
    Write-Log "  [AVISO] Pasta $AppDir ja existe!" "Yellow"
    $resposta = Read-Host "  Deseja DELETAR e recriar? (s/N)"
    if ($resposta -eq "s" -or $resposta -eq "S") {
        Remove-Item -Path $AppDir -Recurse -Force
        Write-Log "  [OK] Pasta removida" "Green"
    } else {
        Write-Log "  [CANCELADO]" "Red"
        exit 0
    }
} else {
    Write-Log "  [OK] Pasta nao existe, sera criada" "Green"
}
Write-Log ""

Write-Log "[3/5] Criando projeto Flutter..." "Yellow"
Write-Log "  ATENCAO: Pode demorar 3-10 minutos!" "Yellow"
Write-Log ""

Set-Location $ProjectRoot

$flutterArgs = @(
    "create",
    "--org", $Organization,
    "--project-name", $AppName,
    "--description", $Description,
    "--platforms", "android,ios,web",
    "app"
)

try {
    & flutter $flutterArgs 2>&1 | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Gray
        Add-Content -Path $LogFile -Value "    $_" -Encoding UTF8
    }
    if (Test-Path "$AppDir\pubspec.yaml") {
        Write-Log ""
        Write-Log "  [OK] Projeto criado!" "Green"
    } else {
        Write-Log "  [ERRO] pubspec.yaml nao gerado!" "Red"
        exit 1
    }
} catch {
    Write-Log "  [ERRO] $_" "Red"
    exit 1
}
Write-Log ""

Write-Log "[4/5] Verificando estrutura..." "Yellow"
$arquivos = @(
    "pubspec.yaml",
    "lib\main.dart",
    "android\app\build.gradle",
    "ios\Runner\Info.plist",
    "web\index.html",
    "test\widget_test.dart"
)
$todosOk = $true
foreach ($arq in $arquivos) {
    $caminho = Join-Path $AppDir $arq
    if (Test-Path $caminho) {
        Write-Log "  [OK] $arq" "Green"
    } else {
        Write-Log "  [FALTA] $arq" "Red"
        $todosOk = $false
    }
}
Write-Log ""

Write-Log "[5/5] Resumo final" "Yellow"
Write-Log ""

if ($todosOk) {
    Write-Log "===========================================================" "Green"
    Write-Log "  PROJETO FLUTTER CRIADO COM SUCESSO!" "Green"
    Write-Log "===========================================================" "Green"
    Write-Log ""
    Write-Log "  Local: $AppDir" "White"
    Write-Log "  Pacote: $Organization.$AppName" "White"
    Write-Log ""
    Write-Log "  Para testar:" "Yellow"
    Write-Log "    cd C:\APP_Finanças\app" "White"
    Write-Log "    flutter run -d chrome" "White"
    Write-Log ""
    Write-Log "  Proximo: Script 09 - setup_pubspec" "Green"
} else {
    Write-Log "  [AVISO] Alguns arquivos faltando" "Yellow"
    Write-Log "  Veja log: $LogFile" "Yellow"
}
Write-Log ""

Set-Location $ProjectRoot
