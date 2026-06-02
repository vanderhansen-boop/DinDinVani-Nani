// lib/presentation/features/transactions/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/transaction.dart';
import 'providers/transaction_providers.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/month_summary_bar.dart';
import 'widgets/transaction_list_item.dart';
import 'widgets/transaction_form.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync      = ref.watch(transactionListProvider);
    final categoriesAx = ref.watch(categoryListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TransactionFilterBar(),
            const MonthSummaryBar(),
            Expanded(
              child: txAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => Center(child: Text('Erro: $e')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Nenhum lançamento neste período',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  // Agrupa por dia
                  final Map<String, List<Transaction>> grouped = {};
                  for (final t in transactions) {
                    final key =
                        '${t.date.day.toString().padLeft(2, "0")}/'
                        '${t.date.month.toString().padLeft(2, "0")}/'
                        '${t.date.year}';
                    grouped.putIfAbsent(key, () => []).add(t);
                  }

                  return categoriesAx.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro: $e')),
                    data: (categories) {
                      final catMap = {for (final c in categories) c.id: c};
                      final keys   = grouped.keys.toList();

                      return RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(transactionListProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: keys.length,
                          itemBuilder: (context, i) {
                            final day  = keys[i];
                            final list = grouped[day]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 12, 16, 4),
                                  child: Text(day,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600])),
                                ),
                                ...list.map((t) {
                                  final cat = catMap[t.categoryId];
                                  return TransactionListItem(
                                    transaction:   t,
                                    categoryName:  cat?.name  ?? '—',
                                    categoryIcon:  cat?.icon  ?? '📦',
                                    categoryColor: cat?.color ?? '#607D8B',
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              TransactionForm(existing: t)),
                                    ),
                                    onDelete: () async {
                                      await ref
                                          .read(saveTransactionProvider)
                                          .delete(t.id);
                                      ref.invalidate(transactionListProvider);
                                    },
                                  );
                                }),
                                const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionForm()),
        ),
        icon:  const Icon(Icons.add_rounded),
        label: const Text('Lançamento'),
      ),
    );
  }
}