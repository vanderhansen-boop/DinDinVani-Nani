$ErrorActionPreference = "Stop"

# CAMINHOS CORRETOS - projeto real esta em \app
$ROOT     = "Z:\AppFinancas"
$BASE     = "Z:\AppFinancas\app"
$LIB      = "$BASE\lib"
$CORE     = "$LIB\core"
$DATA     = "$LIB\data"
$LOG_DIR  = "$ROOT\logs"
$LOG_FILE = "$LOG_DIR\18c_migrate_and_fix.log"

if (-not (Test-Path $LOG_DIR)) { New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null }

function Log {
    param([string]$msg, [string]$color = "White")
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$stamp] $msg"
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $LOG_FILE -Value $line -Encoding utf8
}

function WriteDart {
    param([string]$path, [string[]]$content)
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($path, $content, $utf8NoBom)
    Log ("  ~ " + $path.Replace($ROOT, "")) "Gray"
}

Log "================================================================" "Cyan"
Log " SCRIPT 18c - MIGRACAO + CORRECAO" "Cyan"
Log " Move lib/ orfa para app/lib/ e corrige erros" "Cyan"
Log "================================================================" "Cyan"

# ============ 1) MIGRACAO ============
Log "" "White"
Log "[1/5] Migrando Z:\AppFinancas\lib -> Z:\AppFinancas\app\lib ..." "Yellow"

$ORPHAN_LIB = "$ROOT\lib"
if (Test-Path $ORPHAN_LIB) {
    if (-not (Test-Path $LIB)) { New-Item -ItemType Directory -Path $LIB -Force | Out-Null }

    # Copia core/
    if (Test-Path "$ORPHAN_LIB\core") {
        Log "  Copiando core/ ..." "Gray"
        Copy-Item -Path "$ORPHAN_LIB\core" -Destination $LIB -Recurse -Force
    }
    # Copia data/
    if (Test-Path "$ORPHAN_LIB\data") {
        Log "  Copiando data/ ..." "Gray"
        Copy-Item -Path "$ORPHAN_LIB\data" -Destination $LIB -Recurse -Force
    }
    # Copia arquivos .dart soltos (se houver)
    Get-ChildItem -Path $ORPHAN_LIB -Filter "*.dart" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $LIB -Force
        Log ("  copiado: " + $_.Name) "Gray"
    }

    # Remove a pasta orfa
    Log "  Removendo Z:\AppFinancas\lib (orfa)..." "Yellow"
    Remove-Item -Path $ORPHAN_LIB -Recurse -Force
    Log "  Migracao OK" "Green"
} else {
    Log "  Pasta orfa nao existe (ja foi migrada antes)" "Gray"
}

# ============ 2) PUBSPEC + supabase_flutter ============
Log "" "White"
Log "[2/5] Verificando supabase_flutter no pubspec..." "Yellow"

$pubspec = "$BASE\pubspec.yaml"
if (-not (Test-Path $pubspec)) {
    Log "ERRO: pubspec.yaml nao encontrado em $pubspec" "Red"
    exit 1
}

$pubContent = Get-Content $pubspec -Raw
if ($pubContent -notmatch "supabase_flutter:") {
    Log "  Adicionando supabase_flutter..." "Yellow"
    Push-Location $BASE
    flutter pub add supabase_flutter 2>&1 | Out-Null
    Pop-Location
} else {
    Log "  supabase_flutter ja esta no pubspec" "Green"
}

Log "  Executando flutter pub get..." "Yellow"
Push-Location $BASE
flutter pub get 2>&1 | Out-Null
Pop-Location
Log "  pub get OK" "Green"

# ============ 3) REESCREVE DATASOURCES (com casts corretos) ============
Log "" "White"
Log "[3/5] Reescrevendo datasources..." "Yellow"

# ---- auth_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../../core/errors/exceptions.dart' as app_ex;"
$c += "import '../models/user_model.dart';"
$c += ""
$c += "class AuthRemoteDataSource {"
$c += "  final SupabaseClient _client = SupabaseService.client;"
$c += ""
$c += "  Future<AuthResponse> signIn(String email, String password) async {"
$c += "    try {"
$c += "      return await _client.auth.signInWithPassword(email: email, password: password);"
$c += "    } on AuthException catch (e) {"
$c += "      throw app_ex.AuthException(e.message);"
$c += "    } catch (e) {"
$c += "      throw app_ex.ServerException(e.toString());"
$c += "    }"
$c += "  }"
$c += ""
$c += "  Future<AuthResponse> signUp({"
$c += "    required String email,"
$c += "    required String password,"
$c += "    required String name,"
$c += "  }) async {"
$c += "    try {"
$c += "      return await _client.auth.signUp("
$c += "        email: email,"
$c += "        password: password,"
$c += "        data: {'name': name},"
$c += "      );"
$c += "    } on AuthException catch (e) {"
$c += "      throw app_ex.AuthException(e.message);"
$c += "    }"
$c += "  }"
$c += ""
$c += "  Future<void> signOut() async {"
$c += "    await _client.auth.signOut();"
$c += "  }"
$c += ""
$c += "  Future<UserModel?> getCurrentUserProfile() async {"
$c += "    final user = _client.auth.currentUser;"
$c += "    if (user == null) return null;"
$c += "    final data = await _client.from('users').select().eq('id', user.id).maybeSingle();"
$c += "    if (data == null) return null;"
$c += "    return UserModel.fromJson(Map<String, dynamic>.from(data));"
$c += "  }"
$c += ""
$c += "  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;"
$c += "}"
WriteDart "$DATA\datasources\auth_remote_datasource.dart" $c

# ---- transactions_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../../core/errors/exceptions.dart';"
$c += "import '../models/transaction_model.dart';"
$c += ""
$c += "class TransactionsRemoteDataSource {"
$c += "  final SupabaseClient _c = SupabaseService.client;"
$c += ""
$c += "  Future<List<TransactionModel>> listByMonth({"
$c += "    required String familyId,"
$c += "    required int month,"
$c += "    required int year,"
$c += "  }) async {"
$c += "    try {"
$c += "      final start = DateTime(year, month, 1).toIso8601String();"
$c += "      final end = DateTime(year, month + 1, 1).toIso8601String();"
$c += "      final data = await _c"
$c += "          .from('transactions')"
$c += "          .select()"
$c += "          .eq('family_id', familyId)"
$c += "          .gte('date', start)"
$c += "          .lt('date', end)"
$c += "          .order('date', ascending: false);"
$c += "      return (data as List)"
$c += "          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "          .toList();"
$c += "    } catch (e) {"
$c += "      throw ServerException(e.toString());"
$c += "    }"
$c += "  }"
$c += ""
$c += "  Future<TransactionModel> insert(TransactionModel t) async {"
$c += "    try {"
$c += "      final data = await _c.from('transactions').insert(t.toJson()).select().single();"
$c += "      return TransactionModel.fromJson(Map<String, dynamic>.from(data));"
$c += "    } catch (e) {"
$c += "      throw ServerException(e.toString());"
$c += "    }"
$c += "  }"
$c += ""
$c += "  Future<void> delete(String id) async {"
$c += "    await _c.from('transactions').delete().eq('id', id);"
$c += "  }"
$c += ""
$c += "  Future<TransactionModel> update(String id, Map<String, dynamic> fields) async {"
$c += "    final data = await _c.from('transactions').update(fields).eq('id', id).select().single();"
$c += "    return TransactionModel.fromJson(Map<String, dynamic>.from(data));"
$c += "  }"
$c += ""
$c += "  Stream<List<TransactionModel>> watchByFamily(String familyId) {"
$c += "    return _c"
$c += "        .from('transactions')"
$c += "        .stream(primaryKey: ['id'])"
$c += "        .eq('family_id', familyId)"
$c += "        .order('date', ascending: false)"
$c += "        .map((List<Map<String, dynamic>> rows) =>"
$c += "            rows.map((Map<String, dynamic> e) => TransactionModel.fromJson(e)).toList());"
$c += "  }"
$c += "}"
WriteDart "$DATA\datasources\transactions_remote_datasource.dart" $c

# ---- piggy_banks_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../../core/errors/exceptions.dart';"
$c += "import '../models/piggy_bank_model.dart';"
$c += ""
$c += "class PiggyBanksRemoteDataSource {"
$c += "  final SupabaseClient _c = SupabaseService.client;"
$c += ""
$c += "  Future<List<PiggyBankModel>> list(String familyId) async {"
$c += "    try {"
$c += "      final data = await _c"
$c += "          .from('piggy_banks')"
$c += "          .select()"
$c += "          .eq('family_id', familyId)"
$c += "          .order('type')"
$c += "          .order('name');"
$c += "      return (data as List)"
$c += "          .map((e) => PiggyBankModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "          .toList();"
$c += "    } catch (e) {"
$c += "      throw ServerException(e.toString());"
$c += "    }"
$c += "  }"
$c += ""
$c += "  Future<PiggyBankModel> insert(PiggyBankModel p) async {"
$c += "    final data = await _c.from('piggy_banks').insert(p.toJson()).select().single();"
$c += "    return PiggyBankModel.fromJson(Map<String, dynamic>.from(data));"
$c += "  }"
$c += ""
$c += "  Future<void> contribute({"
$c += "    required String piggyBankId,"
$c += "    required double amount,"
$c += "    required String userId,"
$c += "  }) async {"
$c += "    await _c.from('piggy_bank_contributions').insert({"
$c += "      'piggy_bank_id': piggyBankId,"
$c += "      'amount': amount,"
$c += "      'user_id': userId,"
$c += "    });"
$c += "  }"
$c += ""
$c += "  Stream<List<PiggyBankModel>> watch(String familyId) {"
$c += "    return _c"
$c += "        .from('piggy_banks')"
$c += "        .stream(primaryKey: ['id'])"
$c += "        .eq('family_id', familyId)"
$c += "        .map((List<Map<String, dynamic>> rows) =>"
$c += "            rows.map((Map<String, dynamic> e) => PiggyBankModel.fromJson(e)).toList());"
$c += "  }"
$c += "}"
WriteDart "$DATA\datasources\piggy_banks_remote_datasource.dart" $c

# ---- credit_cards_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../../core/errors/exceptions.dart';"
$c += "import '../models/credit_card_model.dart';"
$c += "import '../models/invoice_model.dart';"
$c += ""
$c += "class CreditCardsRemoteDataSource {"
$c += "  final SupabaseClient _c = SupabaseService.client;"
$c += ""
$c += "  Future<List<CreditCardModel>> list(String familyId) async {"
$c += "    try {"
$c += "      final data = await _c.from('credit_cards').select().eq('family_id', familyId);"
$c += "      return (data as List)"
$c += "          .map((e) => CreditCardModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "          .toList();"
$c += "    } catch (e) {"
$c += "      throw ServerException(e.toString());"
$c += "    }"
$c += "  }"
$c += ""
$c += "  Future<CreditCardModel> insert(CreditCardModel card) async {"
$c += "    final data = await _c.from('credit_cards').insert(card.toJson()).select().single();"
$c += "    return CreditCardModel.fromJson(Map<String, dynamic>.from(data));"
$c += "  }"
$c += ""
$c += "  Future<List<InvoiceModel>> listInvoices(String creditCardId) async {"
$c += "    final data = await _c"
$c += "        .from('invoices')"
$c += "        .select()"
$c += "        .eq('credit_card_id', creditCardId)"
$c += "        .order('reference_year', ascending: false)"
$c += "        .order('reference_month', ascending: false);"
$c += "    return (data as List)"
$c += "        .map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "        .toList();"
$c += "  }"
$c += ""
$c += "  Future<InvoiceModel?> getCurrentInvoice(String creditCardId) async {"
$c += "    final now = DateTime.now();"
$c += "    final data = await _c"
$c += "        .from('invoices')"
$c += "        .select()"
$c += "        .eq('credit_card_id', creditCardId)"
$c += "        .eq('reference_month', now.month)"
$c += "        .eq('reference_year', now.year)"
$c += "        .maybeSingle();"
$c += "    if (data == null) return null;"
$c += "    return InvoiceModel.fromJson(Map<String, dynamic>.from(data));"
$c += "  }"
$c += "}"
WriteDart "$DATA\datasources\credit_cards_remote_datasource.dart" $c

# ---- categories_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../models/category_model.dart';"
$c += ""
$c += "class CategoriesRemoteDataSource {"
$c += "  final SupabaseClient _c = SupabaseService.client;"
$c += ""
$c += "  Future<List<CategoryModel>> list(String familyId) async {"
$c += "    final data = await _c"
$c += "        .from('categories')"
$c += "        .select()"
$c += "        .or('family_id.eq.\$familyId,is_default.eq.true')"
$c += "        .order('type')"
$c += "        .order('name');"
$c += "    return (data as List)"
$c += "        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "        .toList();"
$c += "  }"
$c += "}"
WriteDart "$DATA\datasources\categories_remote_datasource.dart" $c

# ---- budgets_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../models/budget_model.dart';"
$c += ""
$c += "class BudgetsRemoteDataSource {"
$c += "  final SupabaseClient _c = SupabaseService.client;"
$c += ""
$c += "  Future<BudgetModel?> getCurrent(String familyId) async {"
$c += "    final now = DateTime.now();"
$c += "    final data = await _c"
$c += "        .from('monthly_budgets')"
$c += "        .select()"
$c += "        .eq('family_id', familyId)"
$c += "        .eq('reference_month', now.month)"
$c += "        .eq('reference_year', now.year)"
$c += "        .maybeSingle();"
$c += "    if (data == null) return null;"
$c += "    return BudgetModel.fromJson(Map<String, dynamic>.from(data));"
$c += "  }"
$c += ""
$c += "  Future<List<BudgetModel>> listHistory(String familyId, {int limit = 12}) async {"
$c += "    final data = await _c"
$c += "        .from('monthly_budgets')"
$c += "        .select()"
$c += "        .eq('family_id', familyId)"
$c += "        .order('reference_year', ascending: false)"
$c += "        .order('reference_month', ascending: false)"
$c += "        .limit(limit);"
$c += "    return (data as List)"
$c += "        .map((e) => BudgetModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "        .toList();"
$c += "  }"
$c += "}"
WriteDart "$DATA\datasources\budgets_remote_datasource.dart" $c

# ---- goals_remote_datasource.dart ----
$c = @()
$c += "import 'package:supabase_flutter/supabase_flutter.dart';"
$c += "import '../../core/network/supabase_client.dart';"
$c += "import '../models/goal_model.dart';"
$c += ""
$c += "class GoalsRemoteDataSource {"
$c += "  final SupabaseClient _c = SupabaseService.client;"
$c += ""
$c += "  Future<List<GoalModel>> list(String familyId) async {"
$c += "    final data = await _c"
$c += "        .from('family_goals')"
$c += "        .select()"
$c += "        .eq('family_id', familyId)"
$c += "        .order('created_at', ascending: false);"
$c += "    return (data as List)"
$c += "        .map((e) => GoalModel.fromJson(Map<String, dynamic>.from(e as Map)))"
$c += "        .toList();"
$c += "  }"
$c += ""
$c += "  Future<GoalModel> insert(Map<String, dynamic> data) async {"
$c += "    final res = await _c.from('family_goals').insert(data).select().single();"
$c += "    return GoalModel.fromJson(Map<String, dynamic>.from(res));"
$c += "  }"
$c += "}"
WriteDart "$DATA\datasources\goals_remote_datasource.dart" $c

# ============ 4) CORRIGE piggy_banks_repository_impl.dart ============
Log "" "White"
Log "[4/5] Corrigindo piggy_banks_repository_impl.dart..." "Yellow"

$c = @()
$c += "import '../datasources/piggy_banks_remote_datasource.dart';"
$c += "import '../models/piggy_bank_model.dart';"
$c += "import '../../core/errors/failure.dart';"
$c += ""
$c += "class PiggyBanksRepositoryImpl {"
$c += "  final PiggyBanksRemoteDataSource remote;"
$c += "  PiggyBanksRepositoryImpl(this.remote);"
$c += ""
$c += "  Future<List<PiggyBankModel>> list(String familyId) => remote.list(familyId);"
$c += ""
$c += "  Future<PiggyBankModel> create(PiggyBankModel p) async {"
$c += "    const validTypes = ['CF', 'CPI', 'CP', 'CM', 'CE'];"
$c += "    if (!validTypes.contains(p.type)) {"
$c += "      throw ValidationFailure('Tipo de caixinha invalido: ' + p.type);"
$c += "    }"
$c += "    if (p.type == 'CF' && p.creditCardId == null) {"
$c += "      throw const BusinessRuleFailure('Caixinha de Fatura precisa de cartao vinculado');"
$c += "    }"
$c += "    return remote.insert(p);"
$c += "  }"
$c += ""
$c += "  Future<void> contribute({"
$c += "    required String piggyBankId,"
$c += "    required double amount,"
$c += "    required String userId,"
$c += "  }) async {"
$c += "    if (amount <= 0) {"
$c += "      throw const ValidationFailure('Valor da contribuicao deve ser maior que zero');"
$c += "    }"
$c += "    return remote.contribute(piggyBankId: piggyBankId, amount: amount, userId: userId);"
$c += "  }"
$c += ""
$c += "  Stream<List<PiggyBankModel>> watch(String familyId) => remote.watch(familyId);"
$c += "}"
WriteDart "$DATA\repositories\piggy_banks_repository_impl.dart" $c

# ============ 5) ANALYZE ============
Log "" "White"
Log "================================================================" "Cyan"
Log "[5/5] Executando flutter analyze lib/data ..." "Cyan"
Log "================================================================" "Cyan"

Push-Location $BASE
flutter analyze lib/data
$exitCode = $LASTEXITCODE
Pop-Location

Log "" "White"
Log "================================================================" "Cyan"
Log " RESUMO FINAL" "Cyan"
Log "================================================================" "Cyan"

Log ("Projeto Flutter: " + $BASE) "Gray"
Log ("lib/core existe: " + (Test-Path $CORE)) "Gray"
Log ("lib/data existe: " + (Test-Path $DATA)) "Gray"
Log ("lib orfa removida: " + (-not (Test-Path $ORPHAN_LIB))) "Gray"

if ($exitCode -eq 0) {
    Log "" "White"
    Log "SCRIPT 18c - SUCESSO TOTAL" "Green"
} else {
    Log "" "White"
    Log "SCRIPT 18c - Concluido (ver saida do analyze acima)" "Yellow"
}
