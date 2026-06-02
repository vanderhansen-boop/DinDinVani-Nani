import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/credit_card.dart';
import '../../../../domain/entities/invoice.dart';
import 'providers/credit_card_providers.dart';
import 'widgets/credit_card_form.dart';
import 'widgets/invoice_detail_sheet.dart';
import 'widgets/invoice_history_card.dart';

class CreditCardsPage extends ConsumerWidget {
  const CreditCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync    = ref.watch(creditCardsProvider);
    final totalOpenAsync = ref.watch(totalOpenInvoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 Cartões de Crédito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner total aberto – trata AsyncValue corretamente
          totalOpenAsync.when(
            loading: () => const LinearProgressIndicator(),
            error:   (e, _) => const SizedBox.shrink(),
            data:    (total) => total > 0
                ? _TotalOpenBanner(total: total)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: cardsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text('Erro: $e')),
              data:    (cards) => cards.isEmpty
                  ? const Center(
                      child: Text('Nenhum cartão cadastrado.\nToque em + para adicionar.',
                          textAlign: TextAlign.center))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cards.length,
                      itemBuilder: (_, i) => _CardSection(card: cards[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, [CreditCard? card]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreditCardForm(existing: card),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────
class _TotalOpenBanner extends StatelessWidget {
  final double total;
  const _TotalOpenBanner({required this.total});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.red[50],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Total em aberto: ${total.toBRL}',
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}

// ── Seção por cartão ─────────────────────────────────────────
class _CardSection extends ConsumerWidget {
  final CreditCard card;
  const _CardSection({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(currentInvoiceProvider(card.id));
    final historyAsync = ref.watch(invoiceHistoryProvider(card.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do cartão
            Row(
              children: [
                const Icon(Icons.credit_card, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (card.lastFourDigits != null)
                        Text('•••• ${card.lastFourDigits}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Text('Limite: ${card.creditLimit.toBRL}',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
            const Divider(height: 24),

            // Fatura atual
            invoiceAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Text('Erro: $e'),
              data:    (invoice) => invoice == null
                  ? const Text('Sem fatura aberta este mês.')
                  : _InvoiceSummary(
                      invoice: invoice,
                      card:    card,
                    ),
            ),
            const SizedBox(height: 8),

            // Histórico
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error:   (_, __) => const SizedBox.shrink(),
              data:    (hist) {
                if (hist.isEmpty) return const SizedBox.shrink();
                return ExpansionTile(
                  title: const Text('Histórico de faturas',
                      style: TextStyle(fontSize: 13)),
                  children: hist
                      .map((inv) => InvoiceHistoryCard(
                            invoice: inv,
                            onTap:   () => _openDetail(context, card, inv),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext ctx, CreditCard card, Invoice inv) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => InvoiceDetailSheet(card: card, invoice: inv),
    );
  }
}

// ── Resumo da fatura atual ────────────────────────────────────
class _InvoiceSummary extends StatelessWidget {
  final Invoice    invoice;
  final CreditCard card;
  const _InvoiceSummary({required this.invoice, required this.card});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(invoice.monthLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(invoice.totalAmount.toBRL,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: invoice.coveragePercent,
            backgroundColor: Colors.grey[200],
            color: invoice.coveragePercent >= 1 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(invoice.coveragePercent * 100).toStringAsFixed(0)}% coberto',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Falta: ${invoice.remaining.toBRL}',
                  style: const TextStyle(fontSize: 11, color: Colors.red)),
            ],
          ),
        ],
      );
}