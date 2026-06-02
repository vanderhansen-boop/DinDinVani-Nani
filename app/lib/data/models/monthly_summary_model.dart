import '../../domain/entities/monthly_summary.dart';

class MonthlySummaryModel extends MonthlySummary {
  const MonthlySummaryModel({
    required super.year,
    required super.month,
    required super.totalIncome,
    required super.totalExpenses,
    required super.totalSaved,
    required super.balance,
    required super.savingsRate,
    required super.byCategory,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> j) {
    final catRaw = j['by_category'] as Map<String, dynamic>? ?? {};
    final byCategory = catRaw.map(
        (k, v) => MapEntry(k, (v as num).toDouble()));
    final income   = (j['total_income']   as num? ?? 0).toDouble();
    final expenses = (j['total_expenses'] as num? ?? 0).toDouble();
    final saved    = (j['total_saved']    as num? ?? 0).toDouble();
    return MonthlySummaryModel(
      year:          j['year']  as int,
      month:         j['month'] as int,
      totalIncome:   income,
      totalExpenses: expenses,
      totalSaved:    saved,
      balance:       income - expenses,
      savingsRate:   income > 0
          ? ((saved / income) * 100).clamp(0.0, 100.0) : 0.0,
      byCategory:    byCategory,
    );
  }
}