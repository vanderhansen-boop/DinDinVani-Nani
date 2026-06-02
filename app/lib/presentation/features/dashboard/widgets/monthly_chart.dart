import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/monthly_data.dart';

class MonthlyChart extends StatelessWidget {
  final List<MonthlyData> data;
  const MonthlyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVal = data.fold<double>(
      0,
      (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolucao Mensal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.2,
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.income,
                          color: Colors.green,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: entry.value.expense,
                          color: Colors.red,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) return const SizedBox.shrink();
                          return Text(data[i].month, style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData:   const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legend(Colors.green, 'Receita'),
                const SizedBox(width: 16),
                _legend(Colors.red, 'Despesa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    children: [
      Container(width: 10, height: 10, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}
