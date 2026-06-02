import '../entities/budget.dart';
import '../entities/family_goal.dart';
import '../entities/allocation_rule.dart';

abstract class BudgetRepository {
  Future<Budget?>          getBudgetForMonth(String familyId, int year, int month);
  Future<List<Budget>>     getBudgetHistory(String familyId, {int limit = 12});
  Future<Budget>           createOrUpdateBudget(Budget budget);

  Future<List<FamilyGoal>> getGoals(String familyId);
  Future<FamilyGoal>       createGoal(FamilyGoal goal);
  Future<FamilyGoal>       updateGoal(FamilyGoal goal);
  Future<void>             deleteGoal(String id);

  Future<AllocationRule>   getAllocationRule(String familyId);
  Future<void>             saveAllocationRule(String familyId, AllocationRule rule);
}