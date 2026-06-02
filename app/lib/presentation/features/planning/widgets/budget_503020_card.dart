import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/budget.dart';

class Budget503020Card extends StatelessWidget {
  final Budget budget;
  const Budget503020Card({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alocação 50/30/20',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      'Orçamento ${budget.budgetMonth.toString().padLeft(2,"0")}/${budget.budgetYear}  '
                      '(renda de ${budget.referenceMonth.toString().padLeft(2,"0")}/${budget.referenceYear})',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                _PeaceScore(score: budget.peacefulScore),
              ],
            ),
            const SizedBox(height: 16),

            // Renda total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Renda do mês referência',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(budget.totalIncome.toBRL,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Barras 50/30/20
            _BucketBar(
              emoji: '🏠',
              label: 'Necessidades (50%)',
              color: const Color(0xFF1565C0),
              limit: budget.essentialsLimit,
              spent: budget.essentialsSpent,
              progress: budget.essentialsPercent,
            ),
            const SizedBox(height: 10),
            _BucketBar(
              emoji: '🎉',
              label: 'Desejos (30%)',
              color: const Color(0xFFE65100),
              limit: budget.wantsLimit,
              spent: budget.wantsSpent,
              progress: budget.wantsPercent,
            ),
            const SizedBox(height: 10),
            _BucketBar(
              emoji: '💰',
              label: 'Poupança (20%)',
              color: const Color(0xFF1B5E20),
              limit: budget.savingsLimit,
              spent: budget.savingsSpent,
              progress: budget.savingsPercent,
            ),
          ],
        ),
      ),
    );
  }
}

class _BucketBar extends StatelessWidget {
  final String emoji;
  final String label;
  final Color  color;
  final double limit;
  final double spent;
  final double progress;

  const _BucketBar({
    required this.emoji,
    required this.label,
    required this.color,
    required this.limit,
    required this.spent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final overBudget = progress > 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$emoji $label',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(
              '${spent.toBRL} / ${limit.toBRL}',
              style: TextStyle(
                fontSize: 11,
                color: overBudget ? Colors.red : Colors.grey[600],
                fontWeight: overBudget ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
                overBudget ? Colors.red : color),
          ),
        ),
        if (overBudget) ...[
          const SizedBox(height: 2),
          Text(
            '⚠️ Acima do limite em ${(spent - limit).toBRL}',
            style: const TextStyle(fontSize: 10, color: Colors.red,
                fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class _PeaceScore extends StatelessWidget {
  final int score;
  const _PeaceScore({required this.score});

  Color get _color {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String get _label {
    if (score >= 80) return '😊';
    if (score >= 60) return '😐';
    return '😟';
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(_label, style: const TextStyle(fontSize: 20)),
      Text('$score',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _color)),
      Text('paz', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
    ],
  );
}