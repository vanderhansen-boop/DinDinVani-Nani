import '../entities/transaction.dart';

abstract class ITransactionsRepository {
  Future<List<Transaction>> listByMonth({
    required String familyId,
    required int month,
    required int year,
  });
  Future<Transaction> create(Transaction t);
  Future<Transaction> update(String id, Map<String, dynamic> fields);
  Future<void> delete(String id);
  Stream<List<Transaction>> watchByFamily(String familyId);
}
