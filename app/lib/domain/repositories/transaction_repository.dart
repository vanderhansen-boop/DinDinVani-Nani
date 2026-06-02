// lib/domain/repositories/transaction_repository.dart
import '../entities/transaction.dart';
import '../entities/category.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getByMonth(String familyId, int year, int month);
  Future<List<Transaction>> getByFilter({
    required String familyId,
    DateTime?       from,
    DateTime?       to,
    String?         categoryId,
    TransactionType? type,
    String?         search,
  });
  Future<Transaction>       create(Transaction transaction);
  Future<Transaction>       update(Transaction transaction);
  Future<void>              delete(String id);
  Future<List<Category>>    getCategories(String familyId);
}