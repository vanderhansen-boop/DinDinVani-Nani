import '../../domain/entities/piggy_bank.dart';

class PiggyBankModel extends PiggyBank {
  const PiggyBankModel({
    required super.id,
    required super.familyId,
    required super.name,
    required super.emoji,
    required super.type,
    required super.currentBalance,
    required super.targetAmount,
    super.targetDate,
    required super.isActive,
    super.creditCardId,
    super.color,
  });

  factory PiggyBankModel.fromJson(Map<String, dynamic> j) => PiggyBankModel(
    id:             j['id']              as String,
    familyId:       j['family_id']       as String,
    name:           j['name']            as String,
    emoji:          j['emoji']           as String? ?? '🐷',
    type:           _typeFrom(j['type']  as String? ?? 'custom'),
    currentBalance: (j['current_balance'] as num?)?.toDouble() ?? 0.0,
    targetAmount:   (j['target_amount']   as num?)?.toDouble() ?? 0.0,
    targetDate:     j['target_date'] != null ? DateTime.parse(j['target_date'] as String) : null,
    isActive:       j['is_active']  as bool? ?? true,
    creditCardId:   j['credit_card_id'] as String?,
    color:          j['color']          as String?,
  );

  Map<String, dynamic> toJson() => {
    'family_id':       familyId,
    'name':            name,
    'emoji':           emoji,
    'type':            type.name,
    'current_balance': currentBalance,
    'target_amount':   targetAmount,
    'target_date':     targetDate?.toIso8601String(),
    'is_active':       isActive,
    'credit_card_id':  creditCardId,
    'color':           color,
  };

  static PiggyBankType _typeFrom(String s) {
    switch (s) {
      case 'invoice':     return PiggyBankType.invoice;
      case 'installment': return PiggyBankType.installment;
      case 'purpose':     return PiggyBankType.purpose;
      case 'emergency':   return PiggyBankType.emergency;
      case 'monthly':     return PiggyBankType.monthly;
      default:            return PiggyBankType.custom;
    }
  }
}