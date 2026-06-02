import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/piggy_bank.dart';
import 'providers/piggy_bank_providers.dart';
import 'widgets/piggy_bank_card.dart';
import 'widgets/piggy_bank_summary_header.dart';
import 'widgets/piggy_bank_operation_sheet.dart';
import 'widgets/piggy_bank_form.dart';
import 'widgets/piggy_bank_history_sheet.dart';

class PiggyBanksPage extends ConsumerWidget {
  const PiggyBanksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(piggyBankListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PiggyBankSummaryHeader(),
            Expanded(
              child: listAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => Center(child: Text('Erro: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🐷', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 12),
                          const Text('Nenhuma caixinha ainda',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Crie sua primeira caixinha!',
                              style: TextStyle(color: Colors.grey[500])),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => _openForm(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Criar Caixinha'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Ordena: CF e CPI primeiro, depois por tipo
                  final sorted = [...list]..sort((a, b) {
                    const order = [
                      PiggyBankType.invoice,
                      PiggyBankType.installment,
                      PiggyBankType.emergency,
                      PiggyBankType.monthly,
                      PiggyBankType.purpose,
                      PiggyBankType.custom,
                    ];
                    return order.indexOf(a.type).compareTo(order.indexOf(b.type));
                  });

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(piggyBankListProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                      itemCount: sorted.length,
                      itemBuilder: (context, i) {
                        final p = sorted[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PiggyBankCard(
                            piggyBank: p,
                            onTap: () => _openHistory(context, p),
                            onDeposit: () => _openOperation(context, ref, p, true),
                            onWithdraw: () => _openOperation(context, ref, p, false),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Caixinha'),
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, [PiggyBank? existing]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PiggyBankForm(existing: existing)),
    ).then((ok) { if (ok == true) ref.invalidate(piggyBankListProvider); });
  }

  void _openOperation(BuildContext context, WidgetRef ref, PiggyBank p, bool isDeposit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => PiggyBankOperationSheet(piggyBank: p, isDeposit: isDeposit),
    ).then((ok) { if (ok == true) ref.invalidate(piggyBankListProvider); });
  }

  void _openHistory(BuildContext context, PiggyBank p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => PiggyBankHistorySheet(piggyBank: p),
    );
  }
}