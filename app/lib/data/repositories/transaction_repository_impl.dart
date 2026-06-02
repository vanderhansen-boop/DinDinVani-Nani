// lib/data/repositories/transaction_repository_impl.dart
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/remote/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource datasource;
  TransactionRepositoryImpl(this.datasource);

  @override
  Future<List<Transaction>> getByMonth(String familyId, int year, int month) =>
      datasource.getByMonth(familyId, year, month);

  @override
  Future<List<Transaction>> getByFilter({
    required String  familyId,
    DateTime?        from,
    DateTime?        to,
    String?          categoryId,
    TransactionType? type,
    String?          search,
  }) =>
      datasource.getByFilter(
        familyId:   familyId,
        from:       from,
        to:         to,
        categoryId: categoryId,
        type:       type,
        search:     search,
      );

  @override
  Future<Transaction> create(Transaction t) =>
      datasource.create(TransactionModel.fromJson({
        'id':                  '',
        'family_id':           t.familyId,
        'account_id':          t.accountId,
        'credit_card_id':      t.creditCardId,
        'category_id':         t.categoryId,
        'description':         t.description,
        'amount':              t.amount,
        'type':                t.type.name,
        'date':                t.date.toIso8601String(),
        'is_paid':             t.isPaid,
        'recurrence':          t.recurrence.name,
        'installments':        t.installments,
        'current_installment': t.currentInstallment,
        'notes':               t.notes,
        'created_by':          t.createdBy,
      }));

  @override
  Future<Transaction> update(Transaction t) =>
      datasource.update(t as TransactionModel);

  @override
  Future<void> delete(String id) => datasource.delete(id);

  @override
  Future<List<Category>> getCategories(String familyId) =>
      datasource.getCategories(familyId);
}