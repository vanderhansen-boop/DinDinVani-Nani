// lib/domain/usecases/get_transactions.dart
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  Future<List<Transaction>> byMonth(String familyId, int year, int month) =>
      repository.getByMonth(familyId, year, month);

  Future<List<Transaction>> byFilter({
    required String familyId,
    DateTime?        from,
    DateTime?        to,
    String?          categoryId,
    TransactionType? type,
    String?          search,
  }) =>
      repository.getByFilter(
        familyId:   familyId,
        from:       from,
        to:         to,
        categoryId: categoryId,
        type:       type,
        search:     search,
      );
}