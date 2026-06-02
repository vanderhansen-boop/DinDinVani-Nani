import '../../domain/entities/credit_card.dart';

class CreditCardModel {
  final String  id;
  final String  familyId;
  final String  name;
  final double  creditLimit;
  final int     closingDay;
  final int     dueDay;
  final String? lastFourDigits;
  final String? brand;
  final String? color;
  final String? emoji;
  final bool    isActive;
  final String? piggyBankId;

  const CreditCardModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.creditLimit,
    required this.closingDay,
    required this.dueDay,
    this.lastFourDigits,
    this.brand,
    this.color,
    this.emoji,
    this.isActive = true,
    this.piggyBankId,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> j) => CreditCardModel(
        id:             (j['id']             ?? '') as String,
        familyId:       (j['family_id']      ?? '') as String,
        name:           (j['name']           ?? '') as String,
        creditLimit:    (j['credit_limit']   ?? 0  as num).toDouble(),
        closingDay:     (j['closing_day']    ?? 1) as int,
        dueDay:         (j['due_day']        ?? 1) as int,
        lastFourDigits: j['last_four_digits']       as String?,
        brand:          j['brand']                  as String?,
        color:          j['color']                  as String?,
        emoji:          j['emoji']                  as String?,
        isActive:       (j['is_active']      ?? true) as bool,
        piggyBankId:    j['piggy_bank_id']           as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':               id,
        'family_id':        familyId,
        'name':             name,
        'credit_limit':     creditLimit,
        'closing_day':      closingDay,
        'due_day':          dueDay,
        'last_four_digits': lastFourDigits,
        'brand':            brand,
        'color':            color,
        'emoji':            emoji,
        'is_active':        isActive,
        'piggy_bank_id':    piggyBankId,
      };

  CreditCard toEntity() => CreditCard(
        id:             id,
        familyId:       familyId,
        name:           name,
        creditLimit:    creditLimit,
        closingDay:     closingDay,
        dueDay:         dueDay,
        lastFourDigits: lastFourDigits,
        brand:          brand,
        color:          color,
        emoji:          emoji,
        isActive:       isActive,
        piggyBankId:    piggyBankId,
      );

  factory CreditCardModel.fromEntity(CreditCard e) => CreditCardModel(
        id:             e.id,
        familyId:       e.familyId,
        name:           e.name,
        creditLimit:    e.creditLimit,
        closingDay:     e.closingDay,
        dueDay:         e.dueDay,
        lastFourDigits: e.lastFourDigits,
        brand:          e.brand,
        color:          e.color,
        emoji:          e.emoji,
        isActive:       e.isActive,
        piggyBankId:    e.piggyBankId,
      );
}