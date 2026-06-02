import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/cashflow_projection.dart';

class CashflowProjectionCard extends StatelessWidget {
  final List<CashflowProjection> projections;
  const CashflowProjectionCard({super.key, required this.projections});

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Sem projecoes disponiveis')),
        ),
      );
    }

    final maxVal = projections.fold<double>(
      0,
      (m, p) => [m, p.projectedIncome, p.projectedExpenses].reduce((a, b) => a > b ? a : b),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Projecao de Fluxo de Caixa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: maxVal * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: projections.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.projectedIncome))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: projections.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.projectedExpenses))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= projections.length) return const SizedBox.shrink();
                          return Text(
                            projections[i].monthLabel,
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (v, _) {
                          final label = v >= 1000
                              ? 'R\$ ${(v / 1000).toStringAsFixed(0)}k'
                              : 'R\$ ${v.toStringAsFixed(0)}';
                          return Text(label, style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData:   const FlGridData(show: true),
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
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
