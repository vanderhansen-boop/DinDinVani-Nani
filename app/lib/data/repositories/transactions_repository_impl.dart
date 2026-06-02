import '../datasources/transactions_remote_datasource.dart';
import '../models/transaction_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';

class TransactionsRepositoryImpl {
  final TransactionsRemoteDataSource remote;
  TransactionsRepositoryImpl(this.remote);

  Future<List<TransactionModel>> getByMonth({
    required String familyId,
    required int month,
    required int year,
  }) async {
    try {
      return await remote.listByMonth(familyId: familyId, month: month, year: year);
    } on ServerException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  Future<TransactionModel> create(TransactionModel t) async {
    if (t.amount <= 0) {
      throw const ValidationFailure('Valor deve ser maior que zero');
    }
    try {
      return await remote.insert(t);
    } on ServerException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  Future<void> delete(String id) => remote.delete(id);

  Future<TransactionModel> update(String id, Map<String, dynamic> fields) =>
      remote.update(id, fields);

  Stream<List<TransactionModel>> watch(String familyId) => remote.watchByFamily(familyId);
}
