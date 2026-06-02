import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/piggy_bank.dart';
import '../../../../domain/entities/piggy_bank_contribution.dart';
import '../providers/piggy_bank_providers.dart';

class PiggyBankHistorySheet extends ConsumerWidget {
  final PiggyBank piggyBank;
  const PiggyBankHistorySheet({super.key, required this.piggyBank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(piggyBankHistoryProvider(piggyBank.id));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(piggyBank.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('Histórico — ${piggyBank.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text('Erro: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Nenhuma movimentação ainda', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = list[i];
                    final isIn = c.isDeposit;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isIn ? Colors.green : Colors.red).withOpacity(0.1),
                        child: Icon(
                          isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isIn ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      title: Text(c.description ?? (isIn ? 'Depósito' : 'Retirada'),
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(_formatDate(c.createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      trailing: Text(
                        '${isIn ? "+" : "-"}${c.amount.toBRL}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIn ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2,"0")}/${d.month.toString().padLeft(2,"0")}/${d.year} '
      '${d.hour.toString().padLeft(2,"0")}:${d.minute.toString().padLeft(2,"0")}';
}