import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
// lib/presentation/features/transactions/providers/transaction_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/datasources/remote/transaction_remote_datasource.dart';
import '../../../../data/repositories/transaction_repository_impl.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/category.dart';
import '../../../../domain/usecases/get_transactions.dart';
import '../../../../domain/usecases/save_transaction.dart';
import '../../../../domain/usecases/get_categories.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

// ── Infra ──────────────────────────────────────────────────
final transactionDatasourceProvider = Provider<TransactionRemoteDatasource>((ref) =>
    TransactionRemoteDatasourceImpl(Supabase.instance.client));

final transactionRepositoryProvider = Provider((ref) =>
    TransactionRepositoryImpl(ref.watch(transactionDatasourceProvider)));

// ── Use cases ─────────────────────────────────────────────
final getTransactionsProvider = Provider((ref) =>
    GetTransactions(ref.watch(transactionRepositoryProvider)));

final saveTransactionProvider = Provider((ref) =>
    SaveTransaction(ref.watch(transactionRepositoryProvider)));

final getCategoriesProvider = Provider((ref) =>
    GetCategories(ref.watch(transactionRepositoryProvider)));

// ── Estado do filtro ──────────────────────────────────────
class TransactionFilter {
  final int    year;
  final int    month;
  final String? categoryId;
  final TransactionType? type;
  final String? search;

  TransactionFilter({
    required this.year,
    required this.month,
    this.categoryId,
    this.type,
    this.search,
  });

  TransactionFilter copyWith({
    int?    year,
    int?    month,
    String? categoryId,
    TransactionType? type,
    String? search,
    bool clearCategory = false,
    bool clearType     = false,
    bool clearSearch   = false,
  }) =>
      TransactionFilter(
        year:       year       ?? this.year,
        month:      month      ?? this.month,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        type:       clearType     ? null : (type       ?? this.type),
        search:     clearSearch   ? null : (search     ?? this.search),
      );
}

final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) {
  final now = DateTime.now();
  return TransactionFilter(year: now.year, month: now.month);
});

// ── Lista de transacoes (reativa ao filtro) ───────────────
final transactionListProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final filter   = ref.watch(transactionFilterProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  final useCase  = ref.watch(getTransactionsProvider);

  if (filter.categoryId != null || filter.type != null ||
      (filter.search?.isNotEmpty ?? false)) {
    final from = DateTime(filter.year, filter.month, 1);
    final to   = DateTime(filter.year, filter.month + 1, 0, 23, 59, 59);
    return useCase.byFilter(
      familyId:   familyId,
      from:       from,
      to:         to,
      categoryId: filter.categoryId,
      type:       filter.type,
      search:     filter.search,
    );
  }

  return useCase.byMonth(familyId, filter.year, filter.month);
});

// ── Categorias ────────────────────────────────────────────
final categoryListProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(getCategoriesProvider).call(familyId);
});

// ── Totais do mes ─────────────────────────────────────────
final monthTotalsProvider = Provider.autoDispose<({double income, double expense, double balance})>((ref) {
  final txAsync = ref.watch(transactionListProvider);
  return txAsync.when(
    data: (list) {
      double income = 0, expense = 0;
      for (final t in list) {
        if (t.type == TransactionType.income)  income  += t.amount;
        if (t.type == TransactionType.expense) expense += t.amount;
      }
      return (income: income, expense: expense, balance: income - expense);
    },
    loading: () => (income: 0.0, expense: 0.0, balance: 0.0),
    error:   (_, __) => (income: 0.0, expense: 0.0, balance: 0.0),
  );
});