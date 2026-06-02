class PiggyBankContribution {
  final String   id;
  final String   piggyBankId;
  final String   familyId;
  final double   amount;
  final String   type;    // deposit | withdraw | auto_reserve | auto_payment
  final String?  description;
  final DateTime createdAt;
  final String   createdBy;

  const PiggyBankContribution({
    required this.id,
    required this.piggyBankId,
    required this.familyId,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
    required this.createdBy,
  });

  bool get isDeposit  => type == 'deposit'  || type == 'auto_reserve';
  bool get isWithdraw => type == 'withdraw' || type == 'auto_payment';
}