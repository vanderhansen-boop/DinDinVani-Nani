// lib/domain/usecases/save_transaction.dart
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class SaveTransaction {
  final TransactionRepository repository;
  SaveTransaction(this.repository);

  Future<Transaction> create(Transaction t) => repository.create(t);
  Future<Transaction> update(Transaction t) => repository.update(t);
  Future<void>        delete(String id)     => repository.delete(id);
}