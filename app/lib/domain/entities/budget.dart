/// Orcamento mensal baseado na filosofia OD:
/// Renda do mes M define o orcamento do mes M+2
class Budget {
  final String   id;
  final String   familyId;
  final int      referenceYear;   // ano de referencia (M)
  final int      referenceMonth;  // mes de referencia (M)
  final int      budgetYear;      // ano orcado (M+2)
  final int      budgetMonth;     // mes orcado (M+2)
  final double   totalIncome;     // renda bruta do mes M
  final double   essentialsLimit; // 50% — necessidades
  final double   wantsLimit;      // 30% — desejos
  final double   savingsLimit;    // 20% — poupanca/investimento
  final double   essentialsSpent;
  final double   wantsSpent;
  final double   savingsSpent;
  final bool     isLocked;        // true apos mes orcado iniciar

  const Budget({
    required this.id,
    required this.familyId,
    required this.referenceYear,
    required this.referenceMonth,
    required this.budgetYear,
    required this.budgetMonth,
    required this.totalIncome,
    required this.essentialsLimit,
    required this.wantsLimit,
    required this.savingsLimit,
    required this.essentialsSpent,
    required this.wantsSpent,
    required this.savingsSpent,
    required this.isLocked,
  });

  double get totalLimit   => essentialsLimit + wantsLimit + savingsLimit;
  double get totalSpent   => essentialsSpent + wantsSpent + savingsSpent;
  double get totalBalance => totalLimit - totalSpent;

  double get essentialsBalance => essentialsLimit - essentialsSpent;
  double get wantsBalance      => wantsLimit      - wantsSpent;
  double get savingsBalance    => savingsLimit     - savingsSpent;

  double get essentialsPercent =>
      essentialsLimit > 0 ? (essentialsSpent / essentialsLimit).clamp(0.0, 1.0) : 0.0;
  double get wantsPercent =>
      wantsLimit > 0      ? (wantsSpent      / wantsLimit     ).clamp(0.0, 1.0) : 0.0;
  double get savingsPercent =>
      savingsLimit > 0    ? (savingsSpent    / savingsLimit   ).clamp(0.0, 1.0) : 0.0;

  /// Score Paz Financeira: 0-100
  int get peacefulScore {
    int score = 100;
    if (essentialsPercent > 1.0) score -= 30;
    else if (essentialsPercent > 0.9) score -= 15;
    if (wantsPercent > 1.0)      score -= 25;
    else if (wantsPercent > 0.9) score -= 10;
    if (savingsPercent < 0.5)    score -= 20;
    if (totalSpent > totalLimit) score -= 25;
    return score.clamp(0, 100);
  }

  String get referenceMonthLabel =>
      '$referenceMonth/${referenceYear.toString().substring(2)}';
  String get budgetMonthLabel =>
      '$budgetMonth/${budgetYear.toString().substring(2)}';
}