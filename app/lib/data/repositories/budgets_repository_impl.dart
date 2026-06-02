import '../datasources/budgets_remote_datasource.dart';
import '../models/budget_model.dart';

class BudgetsRepositoryImpl {
  final BudgetsRemoteDataSource remote;
  BudgetsRepositoryImpl(this.remote);

  /// Filosofia OD: orcamento do mes atual veio da renda de M-2
  Future<BudgetModel?> getCurrentMonthBudget(String familyId) =>
      remote.getCurrent(familyId);

  Future<List<BudgetModel>> getHistory(String familyId) =>
      remote.listHistory(familyId);
}
