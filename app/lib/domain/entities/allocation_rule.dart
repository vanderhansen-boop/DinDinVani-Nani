/// Regra 50/30/20 — pode ser personalizada por familia
class AllocationRule {
  final double essentialsPercent; // padrao 50
  final double wantsPercent;      // padrao 30
  final double savingsPercent;    // padrao 20

  const AllocationRule({
    required this.essentialsPercent,
    required this.wantsPercent,
    required this.savingsPercent,
  });

  static const defaultRule = AllocationRule(
    essentialsPercent: 50,
    wantsPercent:      30,
    savingsPercent:    20,
  );

  bool get isValid =>
      (essentialsPercent + wantsPercent + savingsPercent) == 100;

  double limitFor(double totalIncome, String bucket) {
    switch (bucket) {
      case 'essentials': return totalIncome * essentialsPercent / 100;
      case 'wants':      return totalIncome * wantsPercent      / 100;
      case 'savings':    return totalIncome * savingsPercent    / 100;
      default:           return 0;
    }
  }
}