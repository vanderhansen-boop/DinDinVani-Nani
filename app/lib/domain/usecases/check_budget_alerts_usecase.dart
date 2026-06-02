import '../entities/budget.dart';

/// Use Case - Verifica alertas de orcamento
/// Niveis: ok, warning (>=80%), danger (>=100%)
class CheckBudgetAlertsUseCase {
  List<BudgetAlert> call(Budget budget) {
    final alerts = <BudgetAlert>[];

    void check(String group, double spent, double budgetValue) {
      if (budgetValue == 0) return;
      final ratio = spent / budgetValue;
      if (ratio >= 1.0) {
        alerts.add(BudgetAlert(group: group, level: 'danger', ratio: ratio));
      } else if (ratio >= 0.8) {
        alerts.add(BudgetAlert(group: group, level: 'warning', ratio: ratio));
      }
    }

    check('essential', budget.essentialSpent, budget.essentialBudget);
    check('lifestyle', budget.lifestyleSpent, budget.lifestyleBudget);
    check('savings', budget.savingsSpent, budget.savingsBudget);

    return alerts;
  }
}

class BudgetAlert {
  final String group;
  final String level;
  final double ratio;
  const BudgetAlert({
    required this.group,
    required this.level,
    required this.ratio,
  });
}
