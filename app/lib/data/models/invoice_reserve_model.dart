import '../../domain/entities/invoice_reserve.dart';

class InvoiceReserveModel extends InvoiceReserve {
  const InvoiceReserveModel({
    required super.id,
    required super.invoiceId,
    required super.familyId,
    super.transactionId,
    required super.type,
    required super.amount,
    required super.description,
    required super.createdAt,
  });

  factory InvoiceReserveModel.fromJson(Map<String, dynamic> j) =>
      InvoiceReserveModel(
    id:            j['id']             as String,
    invoiceId:     j['invoice_id']     as String,
    familyId:      j['family_id']      as String,
    transactionId: j['transaction_id'] as String?,
    type:          (j['type'] as String?) == 'cpi'
        ? ReserveType.cpi : ReserveType.cf,
    amount:        (j['amount']        as num).toDouble(),
    description:   j['description']   as String? ?? '',
    createdAt:     DateTime.parse(j['created_at'] as String),
  );
}