<#
.SYNOPSIS
    Script 09 - Configura pubspec.yaml com todas as dependencias do stack
#>

$ErrorActionPreference = "Continue"
$ProjectRoot = "C:\APP_Finanças"
$AppDir = "$ProjectRoot\app"
$LogDir = "$ProjectRoot\logs"
$LogFile = "$LogDir\09_setup_pubspec.log"
$PubspecFile = "$AppDir\pubspec.yaml"
$PubspecBackup = "$AppDir\pubspec.yaml.backup"

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
Write-Log "  SCRIPT 09 - SETUP PUBSPEC.YAML" "Cyan"
Write-Log "===========================================================" "Cyan"
Write-Log ""

# 1. Verificar projeto
Write-Log "[1/5] Verificando projeto Flutter..." "Yellow"
if (-not (Test-Path $PubspecFile)) {
    Write-Log "  [ERRO] pubspec.yaml nao encontrado em $AppDir" "Red"
    exit 1
}
Write-Log "  [OK] pubspec.yaml encontrado" "Green"
Write-Log ""

# 2. Backup
Write-Log "[2/5] Fazendo backup do pubspec.yaml original..." "Yellow"
Copy-Item -Path $PubspecFile -Destination $PubspecBackup -Force
Write-Log "  [OK] Backup salvo em pubspec.yaml.backup" "Green"
Write-Log ""

# 3. Novo pubspec.yaml
Write-Log "[3/5] Gerando novo pubspec.yaml..." "Yellow"

$novoPubspec = @"
name: dindinvani_nani
description: App financeiro para casal Vani e Nani
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.6

  # Supabase
  supabase_flutter: ^2.5.6

  # Estado - Riverpod
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navegacao
  go_router: ^14.2.0

  # Graficos
  fl_chart: ^0.68.0

  # Formatacao BR (R\$, datas)
  intl: ^0.19.0

  # Env
  flutter_dotenv: ^5.1.0

  # Firebase (notificacoes)
  firebase_core: ^3.3.0
  firebase_messaging: ^15.0.4

  # Storage
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.2.2

  # Models
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  equatable: ^2.0.5

  # Clean Architecture
  dartz: ^0.10.1

  # Utilitarios
  logger: ^2.4.0
  connectivity_plus: ^6.0.3
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code generation
  build_runner: ^2.4.11
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.2
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.13

flutter:
  uses-material-design: true

  assets:
    - .env
    - assets/images/
    - assets/icons/
"@

Set-Content -Path $PubspecFile -Value $novoPubspec -Encoding UTF8
Write-Log "  [OK] Novo pubspec.yaml criado" "Green"
Write-Log ""

# 4. Criar pastas de assets
Write-Log "[4/5] Criando pastas de assets..." "Yellow"
$pastasAssets = @(
    "$AppDir\assets\images",
    "$AppDir\assets\icons"
)
foreach ($p in $pastasAssets) {
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
        Write-Log "  [OK] Criada: $($p.Replace($AppDir, ''))" "Green"
    } else {
        Write-Log "  [JA EXISTE] $($p.Replace($AppDir, ''))" "Gray"
    }
    # Placeholder .gitkeep
    $gitkeep = Join-Path $p ".gitkeep"
    if (-not (Test-Path $gitkeep)) {
        New-Item -ItemType File -Path $gitkeep -Force | Out-Null
    }
}

# Criar .env se nao existir
$envFile = "$AppDir\.env"
if (-not (Test-Path $envFile)) {
    $envContent = @"
# Variaveis de ambiente - DinDinVani&Nani
# NUNCA commitar este arquivo no Git!

SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua_chave_anon_aqui

ENVIRONMENT=development
"@
    Set-Content -Path $envFile -Value $envContent -Encoding UTF8
    Write-Log "  [OK] .env criado (configure depois)" "Green"
} else {
    Write-Log "  [JA EXISTE] .env" "Gray"
}
Write-Log ""

# 5. Instalar dependencias
Write-Log "[5/5] Instalando dependencias com flutter pub get..." "Yellow"
Write-Log "  Isso pode demorar alguns minutos..." "Yellow"
Write-Log ""

Set-Location $AppDir

try {
    & flutter pub get 2>&1 | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Gray
        Add-Content -Path $LogFile -Value "    $_" -Encoding UTF8
    }
    Write-Log ""
    Write-Log "  [OK] Dependencias instaladas!" "Green"
} catch {
    Write-Log "  [ERRO] Falha ao instalar: $_" "Red"
    Write-Log "  Restaurando pubspec.yaml original..." "Yellow"
    Copy-Item -Path $PubspecBackup -Destination $PubspecFile -Force
    exit 1
}
Write-Log ""

Write-Log "===========================================================" "Green"
Write-Log "  SCRIPT 09 CONCLUIDO COM SUCESSO!" "Green"
Write-Log "===========================================================" "Green"
Write-Log ""
Write-Log "  pubspec.yaml configurado com 20+ pacotes" "White"
Write-Log "  Pastas de assets criadas" "White"
Write-Log "  Arquivo .env criado (configure as chaves depois)" "White"
Write-Log ""
Write-Log "  Proximo: Script 10 - init_supabase_local" "Yellow"
Write-Log ""

Set-Location $ProjectRoot
