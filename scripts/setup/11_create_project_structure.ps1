$ErrorActionPreference = "Continue"
$ProjectRoot = "C:\APP_Finanças"
$AppDir = "$ProjectRoot\app"
$LibDir = "$AppDir\lib"
$LogDir = "$ProjectRoot\logs"
$LogFile = "$LogDir\11_create_project_structure.log"

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
Write-Log "  SCRIPT 11 - CREATE PROJECT STRUCTURE" "Cyan"
Write-Log "  Clean Architecture - lib/" "Cyan"
Write-Log "===========================================================" "Cyan"
Write-Log ""

# 1. Verificar projeto Flutter
Write-Log "[1/5] Verificando projeto Flutter..." "Yellow"
if (-not (Test-Path "$AppDir\pubspec.yaml")) {
    Write-Log "  [ERRO] pubspec.yaml nao encontrado" "Red"
    exit 1
}
Write-Log "  [OK] Projeto Flutter encontrado" "Green"
Write-Log ""

# 2. Definir estrutura
Write-Log "[2/5] Criando estrutura de pastas..." "Yellow"
$pastas = @(
    "core\constants",
    "core\errors",
    "core\extensions",
    "core\theme",
    "core\utils",
    "core\widgets",
    "data\datasources\local",
    "data\datasources\remote",
    "data\models",
    "data\repositories",
    "domain\entities",
    "domain\repositories",
    "domain\usecases",
    "presentation\features\auth",
    "presentation\features\dashboard",
    "presentation\features\transactions",
    "presentation\features\piggy_banks",
    "presentation\features\planning",
    "presentation\features\credit_cards",
    "presentation\features\reports",
    "presentation\features\profile",
    "presentation\providers",
    "presentation\router",
    "presentation\shared\widgets",
    "presentation\shared\layouts"
)

$pastasCriadas = 0
foreach ($pasta in $pastas) {
    $caminhoCompleto = Join-Path $LibDir $pasta
    if (-not (Test-Path $caminhoCompleto)) {
        New-Item -ItemType Directory -Path $caminhoCompleto -Force | Out-Null
        $pastasCriadas++
    }
    # .gitkeep
    $gitkeep = Join-Path $caminhoCompleto ".gitkeep"
    if (-not (Test-Path $gitkeep)) {
        New-Item -ItemType File -Path $gitkeep -Force | Out-Null
    }
}
Write-Log "  [OK] $pastasCriadas pastas criadas / $($pastas.Count) total" "Green"
Write-Log ""

# 3. Criar arquivo de barril (exports) - core/core.dart
Write-Log "[3/5] Criando arquivos base..." "Yellow"

# README em cada camada principal
$camadas = @{
    "core" = "Camada CORE - Utilitarios, constantes, temas e widgets compartilhados em todo o app."
    "data" = "Camada DATA - Implementacoes de repositorios, datasources (Supabase, local) e DTOs."
    "domain" = "Camada DOMAIN - Regras de negocio puras: entidades, interfaces de repositorios e casos de uso."
    "presentation" = "Camada PRESENTATION - UI, telas, providers Riverpod e rotas (go_router)."
}

foreach ($camada in $camadas.Keys) {
    $readmePath = Join-Path $LibDir "$camada\README.md"
    $conteudo = @()
    $conteudo += "# $($camada.ToUpper())"
    $conteudo += ""
    $conteudo += $camadas[$camada]
    $conteudo | Out-File -FilePath $readmePath -Encoding UTF8
}
Write-Log "  [OK] READMEs das 4 camadas criados" "Green"

# 4. Criar arquivos base: theme, constants, router
# app_colors.dart
$appColorsPath = Join-Path $LibDir "core\theme\app_colors.dart"
$appColors = @()
$appColors += "import 'package:flutter/material.dart';"
$appColors += ""
$appColors += "/// Cores do app DinDinVani&Nani"
$appColors += "class AppColors {"
$appColors += "  AppColors._();"
$appColors += ""
$appColors += "  // Brand"
$appColors += "  static const Color primary = Color(0xFF6750A4);"
$appColors += "  static const Color secondary = Color(0xFFEC4899);"
$appColors += ""
$appColors += "  // Financeiro"
$appColors += "  static const Color receita = Color(0xFF10B981);"
$appColors += "  static const Color despesa = Color(0xFFEF4444);"
$appColors += "  static const Color caixinha = Color(0xFF3B82F6);"
$appColors += ""
$appColors += "  // Score Paz Financeira"
$appColors += "  static const Color scoreVerde = Color(0xFF22C55E);"
$appColors += "  static const Color scoreAmarelo = Color(0xFFF59E0B);"
$appColors += "  static const Color scoreVermelho = Color(0xFFDC2626);"
$appColors += "}"
$appColors | Out-File -FilePath $appColorsPath -Encoding UTF8

# app_constants.dart
$appConstantsPath = Join-Path $LibDir "core\constants\app_constants.dart"
$appConstants = @()
$appConstants += "/// Constantes globais do app"
$appConstants += "class AppConstants {"
$appConstants += "  AppConstants._();"
$appConstants += ""
$appConstants += "  static const String appName = 'DinDinVani&Nani';"
$appConstants += "  static const String appVersion = '0.1.0';"
$appConstants += ""
$appConstants += "  // Filosofia financeira"
$appConstants += "  static const int mesesDefasagemOrcamento = 2; // OD: renda M -> orcamento M+2"
$appConstants += "  static const double regraSemear = 0.50;  // 50%"
$appConstants += "  static const double regraVoar  = 0.30;  // 30%"
$appConstants += "  static const double regraColher = 0.20;  // 20%"
$appConstants += "}"
$appConstants | Out-File -FilePath $appConstantsPath -Encoding UTF8

# failures.dart
$failuresPath = Join-Path $LibDir "core\errors\failures.dart"
$failures = @()
$failures = @()
$failures += "import 'package:equatable/equatable.dart';"
$failures += ""
$failures += "/// Falhas tratadas no app"
$failures += "abstract class Failure extends Equatable {"
$failures += "  final String message;"
$failures += "  const Failure(this.message);"
$failures += "  @override"
$failures += "  List<Object?> get props => [message];"
$failures += "}"
$failures += ""
$failures += "class ServerFailure extends Failure { const ServerFailure(super.message); }"
$failures += "class CacheFailure extends Failure { const CacheFailure(super.message); }"
$failures += "class NetworkFailure extends Failure { const NetworkFailure(super.message); }"
$failures += "class AuthFailure extends Failure { const AuthFailure(super.message); }"
$failures += "class ValidationFailure extends Failure { const ValidationFailure(super.message); }"
$failures | Out-File -FilePath $failuresPath -Encoding UTF8

Write-Log "  [OK] app_colors.dart, app_constants.dart, failures.dart" "Green"
Write-Log ""

# 5. Verificar estrutura
Write-Log "[5/5] Verificando estrutura final..." "Yellow"
$totalPastas = (Get-ChildItem -Path $LibDir -Directory -Recurse).Count
$totalDart = (Get-ChildItem -Path $LibDir -Filter "*.dart" -Recurse).Count
Write-Log "  [OK] Total de pastas em lib/: $totalPastas" "Green"
Write-Log "  [OK] Total de arquivos .dart: $totalDart" "Green"
Write-Log ""

Write-Log "===========================================================" "Cyan"
Write-Log "  SCRIPT 11 CONCLUIDO COM SUCESSO!" "Green"
Write-Log "===========================================================" "Green"
Write-Log ""
Write-Log "  Estrutura Clean Architecture criada em app\lib\" "White"
Write-Log "  Proximo: Script 12 - create_schema (banco de dados)" "Yellow"
Write-Log ""

Set-Location $ProjectRoot
