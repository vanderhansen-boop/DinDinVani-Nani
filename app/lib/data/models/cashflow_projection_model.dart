import '../../domain/entities/cashflow_projection.dart';

class CashflowProjectionModel extends CashflowProjection {
  const CashflowProjectionModel({
    required super.year,
    required super.month,
    required super.projectedIncome,
    required super.projectedExpense,
    super.isProjection,
  });

  factory CashflowProjectionModel.fromJson(Map<String, dynamic> j) {
    final income   = (j['projected_income']   as num? ?? 0).toDouble();
    final expenses = (j['projected_expenses'] as num? ?? 0).toDouble();
    return CashflowProjectionModel(
      year:            j['year']  as int,
      month:           j['month'] as int,
      projectedIncome: income,
      projectedExpense: expenses,
      isProjection:    j['is_projected'] as bool? ?? true,
    );
  }
}
