enum PiggyBankType {
  invoice,    // CF  — Caixinha de Fatura
  installment,// CPI — Caixinha de Parcela Integral
  purpose,    // CP  — Caixinha de Proposito
  emergency,  // CE  — Caixinha de Emergencia
  monthly,    // CM  — Caixinha do Mes
  custom,     // livre
}

class PiggyBank {
  final String       id;
  final String       familyId;
  final String       name;
  final String       emoji;
  final PiggyBankType type;
  final double       currentBalance;
  final double       targetAmount;
  final DateTime?    targetDate;
  final bool         isActive;
  final String?      creditCardId; // para CF e CPI
  final String?      color;

  const PiggyBank({
    required this.id,
    required this.familyId,
    required this.name,
    required this.emoji,
    required this.type,
    required this.currentBalance,
    required this.targetAmount,
    this.targetDate,
    required this.isActive,
    this.creditCardId,
    this.color,
  });

  double get progressPercent =>
      targetAmount > 0 ? (currentBalance / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => currentBalance >= targetAmount && targetAmount > 0;

  double get remaining =>
      (targetAmount - currentBalance).clamp(0.0, double.infinity);


  bool get isCaixinhaFatura     => type == PiggyBankType.invoice;
  bool get isCaixinhaEmergencia => type == PiggyBankType.emergency;
  bool get isCaixinhaMensal     => type == PiggyBankType.monthly;
  bool get isCaixinhaProposito  => type == PiggyBankType.purpose;
  bool get isCPI                => type == PiggyBankType.installment;
  String get typeLabel {
    switch (type) {
      case PiggyBankType.invoice:     return 'Caixinha de Fatura';
      case PiggyBankType.installment: return 'Parcela Integral';
      case PiggyBankType.purpose:     return 'Proposito';
      case PiggyBankType.emergency:   return 'Emergencia';
      case PiggyBankType.monthly:     return 'Caixinha do Mes';
      case PiggyBankType.custom:      return 'Personalizada';
    }
  }
}