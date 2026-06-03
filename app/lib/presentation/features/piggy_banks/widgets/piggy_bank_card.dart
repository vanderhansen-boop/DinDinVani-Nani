import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/piggy_bank.dart';

class PiggyBankCard extends StatelessWidget {
  final PiggyBank  piggyBank;
  final VoidCallback? onTap;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;

  const PiggyBankCard({
    super.key,
    required this.piggyBank,
    this.onTap,
    this.onDeposit,
    this.onWithdraw,
  });

  Color get _color {
    final hex = piggyBank.color ?? '#607D8B';
    return Color(int.tryParse(hex.replaceFirst('#', '0xFF')) ?? 0xFF607D8B);
  }

  Color get _typeAccent {
    switch (piggyBank.type) {
      case PiggyBankType.invoice:     return const Color(0xFF1565C0);
      case PiggyBankType.installment: return const Color(0xFF6A1B9A);
      case PiggyBankType.emergency:   return const Color(0xFFB71C1C);
      case PiggyBankType.monthly:     return const Color(0xFF1B5E20);
      case PiggyBankType.purpose:     return const Color(0xFFE65100);
      default:                        return const Color(0xFF37474F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _typeAccent;
    final progress = piggyBank.progressPercent;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(piggyBank.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(piggyBank.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(piggyBank.typeLabel,
                            style: TextStyle(fontSize: 11, color: accent)),
                      ],
                    ),
                  ),
                  if (piggyBank.isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('✅ Meta!',
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Valores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guardado', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text(piggyBank.currentBalance.toBRL,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accent)),
                    ],
                  ),
                  if (piggyBank.targetAmount > 0) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Meta', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        Text(piggyBank.targetAmount.toBRL,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ],
                ],
              ),

              // Progress bar
              if (piggyBank.targetAmount > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        piggyBank.isComplete ? Colors.green : accent),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w600)),
                    if (!piggyBank.isComplete)
                      Text('Falta ${piggyBank.remaining.toBRL}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ],

              // Acoes
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onWithdraw,
                      icon: const Icon(Icons.remove_rounded, size: 16),
                      label: const Text('Retirar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onDeposit,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Depositar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
