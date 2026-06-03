class CreditCard {
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

  const CreditCard({
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

  // ── Getters de apresentacao ─────────────────────────────────
  /// Cor segura (sempre com #), fallback azul
  String get displayColor => color ?? '#1565C0';

  /// Emoji seguro
  String get displayEmoji => emoji ?? '💳';

  /// Ultimos 4 digitos seguros
  String get maskedDigits => lastFourDigits ?? '••••';

  /// Rotulo da bandeira capitalizado
  String get brandLabel {
    final b = brand;
    if (b == null || b.isEmpty) return 'CARD';
    return b.toUpperCase();
  }

  CreditCard copyWith({
    String?  id,
    String?  familyId,
    String?  name,
    double?  creditLimit,
    int?     closingDay,
    int?     dueDay,
    String?  lastFourDigits,
    String?  brand,
    String?  color,
    String?  emoji,
    bool?    isActive,
    String?  piggyBankId,
  }) =>
      CreditCard(
        id:             id             ?? this.id,
        familyId:       familyId       ?? this.familyId,
        name:           name           ?? this.name,
        creditLimit:    creditLimit    ?? this.creditLimit,
        closingDay:     closingDay     ?? this.closingDay,
        dueDay:         dueDay         ?? this.dueDay,
        lastFourDigits: lastFourDigits ?? this.lastFourDigits,
        brand:          brand          ?? this.brand,
        color:          color          ?? this.color,
        emoji:          emoji          ?? this.emoji,
        isActive:       isActive       ?? this.isActive,
        piggyBankId:    piggyBankId    ?? this.piggyBankId,
      );
}
