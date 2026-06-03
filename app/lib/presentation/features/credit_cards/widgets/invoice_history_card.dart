import 'package:flutter/material.dart';
import '../../../../domain/entities/invoice.dart';
import '../../../../core/extensions/currency_extension.dart';

class InvoiceHistoryCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceHistoryCard({super.key, required this.invoice, this.onTap});

  Color _statusColor(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.paid:    return Colors.green;
      case InvoiceStatus.overdue: return Colors.red;
      case InvoiceStatus.closed:  return Colors.orange;
      default:                    return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = invoice.invoiceStatus;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _statusColor(status).withValues(alpha: 0.2),
          child: Text(invoice.month.toString(),
              style: TextStyle(
                  color: _statusColor(status),
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(invoice.monthLabel,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Total: ${invoice.totalAmount.toBRL}  •  '
            'Reservado: ${invoice.reservedAmount.toBRL}'),
        trailing: Chip(
          label: Text(invoice.statusLabel,
              style: const TextStyle(fontSize: 11, color: Colors.white)),
          backgroundColor: _statusColor(status),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
