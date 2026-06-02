// lib/data/models/transaction_model.dart
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.familyId,
    required super.accountId,
    super.creditCardId,
    required super.categoryId,
    required super.description,
    required super.amount,
    required super.type,
    required super.date,
    required super.isPaid,
    required super.recurrence,
    super.installments,
    super.currentInstallment,
    super.notes,
    required super.createdBy,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) {
    return TransactionModel(
      id:                 j['id']                  as String,
      familyId:           j['family_id']            as String,
      accountId:          j['account_id']           as String,
      creditCardId:       j['credit_card_id']       as String?,
      categoryId:         j['category_id']          as String,
      description:        j['description']          as String,
      amount:             (j['amount'] as num).toDouble(),
      type:               _typeFromString(j['type'] as String),
      date:               DateTime.parse(j['date']  as String),
      isPaid:             (j['is_paid'] as bool?  ) ?? false,
      recurrence:         _recurrenceFromString(j['recurrence'] as String? ?? 'none'),
      installments:       j['installments']         as int?,
      currentInstallment: j['current_installment']  as int?,
      notes:              j['notes']                as String?,
      createdBy:          j['created_by']           as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'family_id':           familyId,
    'account_id':          accountId,
    'credit_card_id':      creditCardId,
    'category_id':         categoryId,
    'description':         description,
    'amount':              amount,
    'type':                type.name,
    'date':                date.toIso8601String(),
    'is_paid':             isPaid,
    'recurrence':          recurrence.name,
    'installments':        installments,
    'current_installment': currentInstallment,
    'notes':               notes,
    'created_by':          createdBy,
  };

  static TransactionType _typeFromString(String s) {
    switch (s) {
      case 'income':   return TransactionType.income;
      case 'transfer': return TransactionType.transfer;
      default:         return TransactionType.expense;
    }
  }

  static RecurrenceType _recurrenceFromString(String s) {
    switch (s) {
      case 'daily':   return RecurrenceType.daily;
      case 'weekly':  return RecurrenceType.weekly;
      case 'monthly': return RecurrenceType.monthly;
      case 'yearly':  return RecurrenceType.yearly;
      default:        return RecurrenceType.none;
    }
  }
}