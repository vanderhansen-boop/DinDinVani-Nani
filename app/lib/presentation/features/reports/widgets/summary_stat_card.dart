import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/monthly_summary.dart';

/// Cards de KPIs do mes atual
class SummaryStatCards extends StatelessWidget {
  final MonthlySummary summary;
  const SummaryStatCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(child: _StatCard(
            emoji: '💚',
            label: 'Receitas',
            value: summary.totalIncome.toBRL,
            color: Colors.green,
          )),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(
            emoji: '❤️',
            label: 'Despesas',
            value: summary.totalExpenses.toBRL,
            color: Colors.red,
          )),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _StatCard(
            emoji: summary.isPositive ? '✅' : '⚠️',
            label: 'Saldo',
            value: summary.balance.toBRL,
            color: summary.isPositive ? Colors.blue : Colors.orange,
          )),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(
            emoji: '🐷',
            label: 'Taxa de Poupança',
            value: '${summary.savingsRate.toStringAsFixed(1)}%',
            color: Colors.purple,
          )),
        ],
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color  color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color)),
      ],
    ),
  );
}
