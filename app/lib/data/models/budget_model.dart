import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.familyId,
    required super.referenceYear,
    required super.referenceMonth,
    required super.budgetYear,
    required super.budgetMonth,
    required super.totalIncome,
    required super.essentialsLimit,
    required super.wantsLimit,
    required super.savingsLimit,
    required super.essentialsSpent,
    required super.wantsSpent,
    required super.savingsSpent,
    required super.isLocked,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> j) => BudgetModel(
    id:               j['id']                as String,
    familyId:         j['family_id']         as String,
    referenceYear:    j['reference_year']    as int,
    referenceMonth:   j['reference_month']   as int,
    budgetYear:       j['budget_year']       as int,
    budgetMonth:      j['budget_month']      as int,
    totalIncome:      (j['total_income']     as num).toDouble(),
    essentialsLimit:  (j['essentials_limit'] as num).toDouble(),
    wantsLimit:       (j['wants_limit']      as num).toDouble(),
    savingsLimit:     (j['savings_limit']    as num).toDouble(),
    essentialsSpent:  (j['essentials_spent'] as num? ?? 0).toDouble(),
    wantsSpent:       (j['wants_spent']      as num? ?? 0).toDouble(),
    savingsSpent:     (j['savings_spent']    as num? ?? 0).toDouble(),
    isLocked:         j['is_locked']         as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'family_id':       familyId,
    'reference_year':  referenceYear,
    'reference_month': referenceMonth,
    'budget_year':     budgetYear,
    'budget_month':    budgetMonth,
    'total_income':    totalIncome,
    'essentials_limit': essentialsLimit,
    'wants_limit':     wantsLimit,
    'savings_limit':   savingsLimit,
    'is_locked':       isLocked,
  };
}