import '../../domain/entities/budget.dart';
import '../../domain/entities/family_goal.dart';
import '../../domain/entities/allocation_rule.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/remote/budget_remote_datasource.dart';
import '../models/budget_model.dart';
import '../models/family_goal_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDatasource datasource;
  BudgetRepositoryImpl(this.datasource);

  @override
  Future<Budget?> getBudgetForMonth(String familyId, int year, int month) =>
      datasource.getBudgetForMonth(familyId, year, month);

  @override
  Future<List<Budget>> getBudgetHistory(String familyId, {int limit = 12}) =>
      datasource.getBudgetHistory(familyId, limit: limit);

  @override
  Future<Budget> createOrUpdateBudget(Budget budget) =>
      datasource.createOrUpdateBudget(budget as BudgetModel);

  @override
  Future<List<FamilyGoal>> getGoals(String familyId) =>
      datasource.getGoals(familyId);

  @override
  Future<FamilyGoal> createGoal(FamilyGoal goal) =>
      datasource.createGoal(goal as FamilyGoalModel);

  @override
  Future<FamilyGoal> updateGoal(FamilyGoal goal) =>
      datasource.updateGoal(goal as FamilyGoalModel);

  @override
  Future<void> deleteGoal(String id) =>
      datasource.deleteGoal(id);

  @override
  Future<AllocationRule> getAllocationRule(String familyId) =>
      datasource.getAllocationRule(familyId);

  @override
  Future<void> saveAllocationRule(String familyId, AllocationRule rule) =>
      datasource.saveAllocationRule(familyId, rule);
}