import '../../domain/entities/cashflow_projection.dart';

class CashflowProjectionModel extends CashflowProjection {
  const CashflowProjectionModel({
    required super.year,
    required super.month,
    required super.projectedIncome,
    required super.projectedExpenses,
    required super.projectedBalance,
    required super.recurringExpenses,
    required super.invoicesDue,
    required super.piggyBankObligations,
    required super.isProjected,
  });

  factory CashflowProjectionModel.fromJson(Map<String, dynamic> j) {
    final income   = (j['projected_income']   as num? ?? 0).toDouble();
    final expenses = (j['projected_expenses'] as num? ?? 0).toDouble();
    return CashflowProjectionModel(
      year:                 j['year']  as int,
      month:                j['month'] as int,
      projectedIncome:      income,
      projectedExpenses:    expenses,
      projectedBalance:     income - expenses,
      recurringExpenses:    (j['recurring_expenses']     as num? ?? 0).toDouble(),
      invoicesDue:          (j['invoices_due']           as num? ?? 0).toDouble(),
      piggyBankObligations: (j['piggy_bank_obligations'] as num? ?? 0).toDouble(),
      isProjected:          j['is_projected'] as bool? ?? true,
    );
  }
}