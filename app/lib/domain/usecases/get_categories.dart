// lib/domain/usecases/get_categories.dart
import '../entities/category.dart';
import '../repositories/transaction_repository.dart';

class GetCategories {
  final TransactionRepository repository;
  GetCategories(this.repository);

  Future<List<Category>> call(String familyId) =>
      repository.getCategories(familyId);
}