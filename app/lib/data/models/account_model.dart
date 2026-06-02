class AccountModel {
  final String id;
  final String familyId;
  final String name;
  final String type; // checking, savings, wallet
  final double balance;
  final String? bankName;
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.type,
    required this.balance,
    this.bankName,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
        id: j['id'] as String,
        familyId: j['family_id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        balance: (j['balance'] as num).toDouble(),
        bankName: j['bank_name'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'family_id': familyId,
        'name': name,
        'type': type,
        'balance': balance,
        'bank_name': bankName,
      };
}
