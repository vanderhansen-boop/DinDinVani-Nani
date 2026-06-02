import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/piggy_bank.dart';
import '../providers/piggy_bank_providers.dart';

class PiggyBankSummaryHeader extends ConsumerWidget {
  const PiggyBankSummaryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total  = ref.watch(piggyBankTotalBalanceProvider);
    final totals = ref.watch(piggyBankTotalsProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🐷', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Total guardado', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text(total.toBRL,
              style: const TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TypeBadge(emoji: '💳', label: 'Fatura',
                    value: totals[PiggyBankType.invoice]    ?? 0),
                _TypeBadge(emoji: '📦', label: 'CPI',
                    value: totals[PiggyBankType.installment] ?? 0),
                _TypeBadge(emoji: '🎯', label: 'Meta',
                    value: totals[PiggyBankType.purpose]    ?? 0),
                _TypeBadge(emoji: '🛡️', label: 'Emergência',
                    value: totals[PiggyBankType.emergency]  ?? 0),
                _TypeBadge(emoji: '📅', label: 'Mês',
                    value: totals[PiggyBankType.monthly]    ?? 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final double value;
  const _TypeBadge({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text('$emoji $label', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value.toBRL, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}