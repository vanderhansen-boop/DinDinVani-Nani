import '../entities/budget.dart';
import '../entities/allocation_rule.dart';
import '../repositories/budget_repository.dart';

class GetCurrentBudget {
  final BudgetRepository repository;
  GetCurrentBudget(this.repository);

  /// Retorna o orcamento ativo (mes atual) ou null se nao houver
  Future<Budget?> call(String familyId) {
    final now = DateTime.now();
    return repository.getBudgetForMonth(familyId, now.year, now.month);
  }

  /// Calcula orcamento de M+2 a partir da renda de M
  Budget buildFromIncome({
    required String       familyId,
    required double       totalIncome,
    required AllocationRule rule,
    DateTime?             referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final budgetDate = DateTime(ref.year, ref.month + 2, 1);

    return Budget(
      id:               '',
      familyId:         familyId,
      referenceYear:    ref.year,
      referenceMonth:   ref.month,
      budgetYear:       budgetDate.year,
      budgetMonth:      budgetDate.month,
      totalIncome:      totalIncome,
      essentialsLimit:  rule.limitFor(totalIncome, 'essentials'),
      wantsLimit:       rule.limitFor(totalIncome, 'wants'),
      savingsLimit:     rule.limitFor(totalIncome, 'savings'),
      essentialsSpent:  0,
      wantsSpent:       0,
      savingsSpent:     0,
      isLocked:         false,
    );
  }
}