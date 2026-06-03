import '../../domain/entities/invoice_reserve.dart';

class InvoiceReserveModel extends InvoiceReserve {
  const InvoiceReserveModel({
    required super.id,
    required super.invoiceId,
    required super.transactionId,
    required super.amount,
    required super.description,
    required super.createdAt,
  });

  factory InvoiceReserveModel.fromJson(Map<String, dynamic> j) =>
      InvoiceReserveModel(
        id:            j['id']             as String,
        invoiceId:     j['invoice_id']     as String,
        transactionId: j['transaction_id'] as String? ?? '',
        amount:        (j['amount']        as num).toDouble(),
        description:   j['description']    as String? ?? '',
        createdAt:     j['created_at'] != null
            ? DateTime.parse(j['created_at'] as String)
            : DateTime.now(),
      );
}
