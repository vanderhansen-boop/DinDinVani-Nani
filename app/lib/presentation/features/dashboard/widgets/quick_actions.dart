// lib/presentation/features/dashboard/widgets/quick_actions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ações Rápidas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionButton(icon: Icons.add_circle_outline_rounded,  label: 'Lançamento', color: Colors.blue,   onTap: () => context.push('/transactions/new')),
            _ActionButton(icon: Icons.savings_outlined,            label: 'Caixinha',   color: Colors.purple, onTap: () => context.push('/piggy-banks')),
            _ActionButton(icon: Icons.credit_card_outlined,        label: 'Cartão',     color: Colors.teal,   onTap: () => context.push('/credit-cards')),
            _ActionButton(icon: Icons.bar_chart_rounded,           label: 'Relatório',  color: Colors.orange, onTap: () => context.push('/reports')),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
