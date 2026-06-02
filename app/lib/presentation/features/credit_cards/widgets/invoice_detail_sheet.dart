import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/credit_card.dart';
import '../../../../domain/entities/invoice.dart';
import '../../../../domain/entities/invoice_reserve.dart';
import '../providers/credit_card_providers.dart';

class InvoiceDetailSheet extends ConsumerWidget {
  final CreditCard card;
  final Invoice    invoice;

  const InvoiceDetailSheet({
    super.key,
    required this.card,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfAsync = card.piggyBankId != null
        ? ref.watch(cfBalanceProvider(card.piggyBankId!))
        : const AsyncData<double>(0.0);

    final reservesAsync = ref.watch(invoiceReservesProvider(invoice.id));

    final cfBalance = cfAsync.valueOrNull ?? 0.0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              'Fatura ${invoice.monthLabel}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _StatusChip(status: invoice.invoiceStatus),
            const SizedBox(height: 20),

            // Valores
            _Row('Total',             invoice.totalAmount.toBRL),
            _Row('Reservado (CF)',    invoice.reservedAmount.toBRL),
            _Row('Pago',             invoice.paidAmount.toBRL),
            _Row('Falta cobrir',     invoice.remaining.toBRL,
                valueColor: invoice.remaining > 0 ? Colors.red : Colors.green),
            const Divider(height: 32),

            // Cobertura
            Text('Cobertura CF: ${(invoice.coveragePercent * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: invoice.coveragePercent,
              backgroundColor: Colors.grey[200],
              color: invoice.coveragePercent >= 1 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 4),
            Text('Saldo CF: ${cfBalance.toBRL}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 32),

            // Datas
            if (invoice.closingDate != null)
              _DateInfo('📅 Fecha', invoice.closingDate!),
            if (invoice.dueDate != null)
              _DateInfo('💳 Vence', invoice.dueDate!),
            const SizedBox(height: 16),

            // Botão pagar
            if (invoice.invoiceStatus != InvoiceStatus.paid &&
                invoice.invoiceStatus != InvoiceStatus.overdue) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como Paga'),
                onPressed: () {
                  ref
                      .read(manageCreditCardProvider)
                      .payInvoice(invoice.id, invoice.totalAmount);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],

            // Reservas
            Text('Lançamentos nesta fatura',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            reservesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Text('Erro: $e'),
              data:    (reserves) => Column(
                children: reserves
                    .map((r) => _ReserveItem(reserve: r))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────
class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: valueColor)),
          ],
        ),
      );
}

class _DateInfo extends StatelessWidget {
  final String   label;
  final DateTime date;
  const _DateInfo(this.label, this.date);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('$label  '),
            Text('${date.day.toString().padLeft(2,'0')}/'
                '${date.month.toString().padLeft(2,'0')}/'
                '${date.year}'),
          ],
        ),
      );
}

class _ReserveItem extends StatelessWidget {
  final InvoiceReserve reserve;
  const _ReserveItem({required this.reserve});

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        title: Text(reserve.description),
        trailing: Text(reserve.amount.toBRL,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${reserve.createdAt.day.toString().padLeft(2,'0')}/'
          '${reserve.createdAt.month.toString().padLeft(2,'0')}/'
          '${reserve.createdAt.year}',
          style: const TextStyle(fontSize: 11),
        ),
      );
}

class _StatusChip extends StatelessWidget {
  final InvoiceStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case InvoiceStatus.paid:    return Colors.green;
      case InvoiceStatus.overdue: return Colors.red;
      case InvoiceStatus.closed:  return Colors.orange;
      default:                    return Colors.blue;
    }
  }

  String get _label {
    switch (status) {
      case InvoiceStatus.paid:    return '✅ Paga';
      case InvoiceStatus.overdue: return '❌ Vencida';
      case InvoiceStatus.closed:  return '🔒 Fechada';
      default:                    return '🟡 Aberta';
    }
  }

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(_label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: _color,
      );
}