import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/monthly_summary.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlySummary> data;
  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sem dados'));
    }
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data
                .map((e) => e.income > e.expense ? e.income : e.expense)
                .reduce((a, b) => a > b ? a : b) *
            1.2,
        barGroups: data.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: s.income,
                color: Colors.green,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: s.expense,
                color: Colors.red,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[idx].label,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData:    const FlGridData(show: false),
        borderData:  FlBorderData(show: false),
      ),
    );
  }
}