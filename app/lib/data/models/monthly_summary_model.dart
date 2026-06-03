import '../../domain/entities/monthly_summary.dart';

class MonthlySummaryModel extends MonthlySummary {
  const MonthlySummaryModel({
    required super.year,
    required super.month,
    required super.income,
    required super.expense,
    super.byCategory,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> j) {
    final income   = (j['total_income']   as num? ?? 0).toDouble();
    final expenses = (j['total_expenses'] as num? ?? 0).toDouble();

    final catRaw = j['by_category'] as Map<String, dynamic>? ?? {};
    final total  = catRaw.values.fold<double>(
        0, (s, v) => s + (v as num).toDouble());
    final byCategory = catRaw.entries.map((e) {
      final amount = (e.value as num).toDouble();
      return CategoryBreakdown(
        categoryId:    e.key,
        categoryName:  e.key,
        categoryEmoji: '',
        amount:        amount,
        percentage:    total > 0 ? (amount / total) * 100 : 0,
      );
    }).toList();

    return MonthlySummaryModel(
      year:       j['year']  as int,
      month:      j['month'] as int,
      income:     income,
      expense:    expenses,
      byCategory: byCategory,
    );
  }
}
