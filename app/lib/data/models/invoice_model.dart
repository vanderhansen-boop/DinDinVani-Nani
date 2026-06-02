import '../../domain/entities/invoice.dart';

class InvoiceModel {
  final String    id;
  final String    creditCardId;
  final int       month;
  final int       year;
  final double    totalAmount;
  final double    reservedAmount;
  final String    status;
  final DateTime? dueDate;
  final DateTime? closingDate;

  const InvoiceModel({
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

  factory InvoiceModel.fromJson(Map<String, dynamic> j) => InvoiceModel(
        id:             j['id']              as String,
        creditCardId:   j['credit_card_id']  as String,
        month:          j['month']           as int,
        year:           j['year']            as int,
        totalAmount:    (j['total_amount']   as num).toDouble(),
        reservedAmount: (j['reserved_amount'] as num? ?? 0).toDouble(),
        status:         j['status']          as String? ?? 'open',
        dueDate:        j['due_date']    != null
            ? DateTime.parse(j['due_date'] as String)
            : null,
        closingDate: j['closing_date'] != null
            ? DateTime.parse(j['closing_date'] as String)
            : null,
      );

  Invoice toEntity() => Invoice(
        id:             id,
        creditCardId:   creditCardId,
        month:          month,
        year:           year,
        totalAmount:    totalAmount,
        reservedAmount: reservedAmount,
        status:         status,
        dueDate:        dueDate,
        closingDate:    closingDate,
      );
}