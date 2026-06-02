import '../entities/allocation_rule.dart';
import '../repositories/budget_repository.dart';

class ManageAllocationRule {
  final BudgetRepository repository;
  ManageAllocationRule(this.repository);

  Future<AllocationRule> get(String familyId) =>
      repository.getAllocationRule(familyId);

  Future<void> save(String familyId, AllocationRule rule) =>
      repository.saveAllocationRule(familyId, rule);
}