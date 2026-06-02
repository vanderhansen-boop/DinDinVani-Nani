class InvoiceReserve {
  final String  id;
  final String  invoiceId;
  final String  transactionId;
  final double  amount;
  final String  description;
  final DateTime createdAt;

  const InvoiceReserve({
    required this.id,
    required this.invoiceId,
    required this.transactionId,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory InvoiceReserve.fromMap(Map<String, dynamic> m) => InvoiceReserve(
        id:            m['id']             as String,
        invoiceId:     m['invoice_id']     as String,
        transactionId: m['transaction_id'] as String? ?? '',
        amount:        (m['amount']        as num).toDouble(),
        description:   m['description']    as String? ?? '',
        createdAt:     m['created_at'] != null
            ? DateTime.parse(m['created_at'] as String)
            : DateTime.now(),
      );
}