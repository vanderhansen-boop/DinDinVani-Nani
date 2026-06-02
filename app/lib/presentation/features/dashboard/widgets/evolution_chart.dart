// lib/presentation/features/dashboard/widgets/evolution_chart.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/monthly_data.dart';

class EvolutionChart extends StatelessWidget {
  final List<MonthlyData> data;
  const EvolutionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Sem dados de evolução')),
      ));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução Mensal', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final d = data[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('R\$ ${d.balance.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(d.label, style: const TextStyle(fontSize: 10)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}