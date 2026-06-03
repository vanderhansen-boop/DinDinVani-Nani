// lib/presentation/features/transactions/widgets/transaction_list_item.dart
import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction  transaction;
  final String       categoryName;
  final String       categoryIcon;
  final String       categoryColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.onTap,
    this.onDelete,
  });

  Color get _typeColor {
    switch (transaction.type) {
      case TransactionType.income:   return Colors.green;
      case TransactionType.transfer: return Colors.blue;
      default:                       return Colors.red;
    }
  }

  String get _typeSign =>
      transaction.type == TransactionType.income ? '+' : '-';

  IconData get _recurrenceIcon {
    if (transaction.isInstallment) return Icons.credit_card_rounded;
    if (transaction.isRecurring)   return Icons.repeat_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.tryParse(categoryColor.replaceFirst('#', '0xFF')) ?? 0xFF607D8B,
    );

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir lançamento?'),
            content: Text(transaction.description),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(categoryIcon, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(categoryName,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(width: 6),
            Icon(_recurrenceIcon, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 2),
            Text(
              _formatDate(transaction.date),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            if (transaction.isInstallment) ...[
              const SizedBox(width: 4),
              Text(
                '${transaction.currentInstallment}/${transaction.installments}',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$_typeSign${transaction.amount.toBRL}',
              style: TextStyle(
                color: _typeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (!transaction.isPaid)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('pendente',
                    style: TextStyle(fontSize: 9, color: Colors.orange)),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}';
}
