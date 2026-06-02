// lib/presentation/features/dashboard/widgets/balance_card.dart
import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double monthIncome;
  final double monthExpense;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Total', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              totalBalance.toBRL,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _InfoChip(label: 'Receitas', value: monthIncome, color: Colors.greenAccent)),
                const SizedBox(width: 12),
                Expanded(child: _InfoChip(label: 'Despesas', value: monthExpense, color: Colors.redAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _InfoChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value.toBRL, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}