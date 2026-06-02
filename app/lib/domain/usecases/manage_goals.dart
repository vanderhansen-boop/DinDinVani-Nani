import '../entities/family_goal.dart';
import '../repositories/budget_repository.dart';

class ManageGoals {
  final BudgetRepository repository;
  ManageGoals(this.repository);

  Future<List<FamilyGoal>> getAll(String familyId) =>
      repository.getGoals(familyId);

  Future<FamilyGoal> create(FamilyGoal goal) =>
      repository.createGoal(goal);

  Future<FamilyGoal> update(FamilyGoal goal) =>
      repository.updateGoal(goal);

  Future<void> delete(String id) =>
      repository.deleteGoal(id);
}