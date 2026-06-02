import 'package:flutter/material.dart';
import '../../../../domain/entities/dashboard_summary.dart';

class SummaryCards extends StatelessWidget {
  final DashboardSummary summary;
  const SummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _card(
          context,
          icon: Icons.account_balance_wallet,
          label: 'Saldo Total',
          value: summary.totalBalance,
          color: Colors.blue,
        ),
        _card(
          context,
          icon: Icons.trending_up,
          label: 'Receita do Mes',
          value: summary.monthIncome,
          color: Colors.green,
        ),
        _card(
          context,
          icon: Icons.trending_down,
          label: 'Despesas do Mes',
          value: summary.monthExpense,
          color: Colors.red,
        ),
        _card(
          context,
          icon: Icons.savings,
          label: 'Total Caixinhas',
          value: summary.piggyBanksTotal,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
