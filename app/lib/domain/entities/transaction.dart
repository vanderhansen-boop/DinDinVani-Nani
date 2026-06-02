// lib/domain/entities/transaction.dart

enum TransactionType { income, expense, transfer }
enum RecurrenceType  { none, daily, weekly, monthly, yearly }

class Transaction {
  final String          id;
  final String          familyId;
  final String          accountId;
  final String?         creditCardId;
  final String          categoryId;
  final String          description;
  final double          amount;
  final TransactionType type;
  final DateTime        date;
  final bool            isPaid;
  final RecurrenceType  recurrence;
  final int?            installments;
  final int?            currentInstallment;
  final String?         notes;
  final String          createdBy;

  const Transaction({
    required this.id,
    required this.familyId,
    required this.accountId,
    this.creditCardId,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.isPaid,
    required this.recurrence,
    this.installments,
    this.currentInstallment,
    this.notes,
    required this.createdBy,
  });

  bool get isCredit      => creditCardId != null;
  bool get isInstallment => (installments ?? 0) > 1;
  bool get isRecurring   => recurrence != RecurrenceType.none;

  bool get isCreditCardExpense => creditCardId != null && type == TransactionType.expense;
}