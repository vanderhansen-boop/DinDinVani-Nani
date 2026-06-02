// lib/data/models/dashboard_summary_model.dart
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/monthly_data.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalBalance,
    required super.monthIncome,
    required super.monthExpense,
    required super.piggyBanksTotal,
    required super.invoiceCoverage,
    required super.peaceScore,
    required super.alerts,
    required super.monthlyEvolution,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final evolution = (json['monthly_evolution'] as List? ?? [])
        .map((e) => MonthlyData(
              month:   e['month']   as String,
              income:  (e['income']  as num).toDouble(),
              expense: (e['expense'] as num).toDouble(),
            ))
        .toList();

    return DashboardSummaryModel(
      totalBalance:     (json['total_balance']    as num?)?.toDouble() ?? 0,
      monthIncome:      (json['month_income']     as num?)?.toDouble() ?? 0,
      monthExpense:     (json['month_expense']    as num?)?.toDouble() ?? 0,
      piggyBanksTotal:  (json['piggy_banks_total']as num?)?.toDouble() ?? 0,
      invoiceCoverage:  (json['invoice_coverage'] as num?)?.toDouble() ?? 0,
      peaceScore:       (json['peace_score']      as num?)?.toInt()    ?? 0,
      alerts:           List<String>.from(json['alerts'] ?? []),
      monthlyEvolution: evolution,
    );
  }

  // Fallback local quando Supabase nao responde
  factory DashboardSummaryModel.empty() => const DashboardSummaryModel(
        totalBalance:    0,
        monthIncome:     0,
        monthExpense:    0,
        piggyBanksTotal: 0,
        invoiceCoverage: 0,
        peaceScore:      0,
        alerts:          [],
        monthlyEvolution:[],
      );
}