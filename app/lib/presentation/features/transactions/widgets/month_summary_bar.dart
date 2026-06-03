// lib/presentation/features/transactions/widgets/month_summary_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../providers/transaction_providers.dart';

class MonthSummaryBar extends ConsumerWidget {
  const MonthSummaryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(monthTotalsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Item(label: 'Receitas', value: totals.income,  color: Colors.green),
          _Divider(),
          _Item(label: 'Despesas', value: totals.expense, color: Colors.red),
          _Divider(),
          _Item(label: 'Saldo',    value: totals.balance,
              color: totals.balance >= 0 ? Colors.blue : Colors.orange),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  const _Item({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      Text(value.toBRL,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: Colors.grey.shade300);
}
