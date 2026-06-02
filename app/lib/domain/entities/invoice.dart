enum InvoiceStatus { open, closed, paid, overdue }

class Invoice {
  final String        id;
  final String        creditCardId;
  final int           month;
  final int           year;
  final double        totalAmount;
  final double        reservedAmount;
  final String        status; // open | closed | paid | overdue
  final DateTime?     dueDate;
  final DateTime?     closingDate;

  const Invoice({
    required this.id,
    required this.creditCardId,
    required this.month,
    required this.year,
    required this.totalAmount,
    required this.reservedAmount,
    required this.status,
    this.dueDate,
    this.closingDate,
  });

  // ── Getters utilitários ────────────────────────────────────
  double get remaining =>
      (totalAmount - reservedAmount).clamp(0, double.infinity);

  double get coveragePercent =>
      totalAmount <= 0 ? 1.0 : (reservedAmount / totalAmount).clamp(0.0, 1.0);

  double get paidAmount => reservedAmount;

  InvoiceStatus get invoiceStatus {
    switch (status) {
      case 'paid':    return InvoiceStatus.paid;
      case 'closed':  return InvoiceStatus.closed;
      case 'overdue': return InvoiceStatus.overdue;
      default:        return InvoiceStatus.open;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'paid':    return '✅ Paga';
      case 'closed':  return '🔒 Fechada';
      case 'overdue': return '❌ Vencida';
      default:        return '🟡 Aberta';
    }
  }

  String get monthLabel {
    const months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[month]}/$year';
  }

  Invoice copyWith({
    String?   id,
    String?   creditCardId,
    int?      month,
    int?      year,
    double?   totalAmount,
    double?   reservedAmount,
    String?   status,
    DateTime? dueDate,
    DateTime? closingDate,
  }) =>
      Invoice(
        id:             id             ?? this.id,
        creditCardId:   creditCardId   ?? this.creditCardId,
        month:          month          ?? this.month,
        year:           year           ?? this.year,
        totalAmount:    totalAmount    ?? this.totalAmount,
        reservedAmount: reservedAmount ?? this.reservedAmount,
        status:         status         ?? this.status,
        dueDate:        dueDate        ?? this.dueDate,
        closingDate:    closingDate    ?? this.closingDate,
      );
}