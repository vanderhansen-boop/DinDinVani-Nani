// lib/domain/entities/dashboard_summary.dart
import 'monthly_data.dart';

/// Alerta exibido no dashboard
class DashboardAlert {
  final String message;
  final String type; // 'warning' | 'danger' | 'info'
  const DashboardAlert({required this.message, this.type = 'info'});
  @override
  String toString() => message;
}

class DashboardSummary {
  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final double piggyBanksTotal;
  final double invoiceCoverage;   // % faturas cobertas pela CF
  final int    peaceScore;        // 0-100
  final List<String> alerts;
  final List<MonthlyData> monthlyEvolution;

  const DashboardSummary({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.piggyBanksTotal,
    required this.invoiceCoverage,
    required this.peaceScore,
    required this.alerts,
    required this.monthlyEvolution,
  });

  DashboardSummary copyWith({
    double? totalBalance,
    double? monthIncome,
    double? monthExpense,
    double? piggyBanksTotal,
    double? invoiceCoverage,
    int?    peaceScore,
    List<String>? alerts,
    List<MonthlyData>? monthlyEvolution,
  }) {
    return DashboardSummary(
      totalBalance:      totalBalance      ?? this.totalBalance,
      monthIncome:       monthIncome       ?? this.monthIncome,
      monthExpense:      monthExpense      ?? this.monthExpense,
      piggyBanksTotal:   piggyBanksTotal   ?? this.piggyBanksTotal,
      invoiceCoverage:   invoiceCoverage   ?? this.invoiceCoverage,
      peaceScore:        peaceScore        ?? this.peaceScore,
      alerts:            alerts            ?? this.alerts,
      monthlyEvolution:  monthlyEvolution  ?? this.monthlyEvolution,
    );
  }

  // Aliases usados nas telas
  int    get peacefulScore    => peaceScore;
  double get availableBalance => totalBalance;
  double get invoiceReserved  => piggyBanksTotal * (invoiceCoverage / 100.0);
  double get cpiReserved      => 0.0; // calculado via caixinhas
  List<MonthlyData> get evolution => monthlyEvolution;
}