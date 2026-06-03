import '../entities/budget.dart';
import '../entities/piggy_bank.dart';
import '../entities/invoice.dart';

/// Use Case - Score de Paz Financeira (0 a 100)
class CalculateScorePazFinanceiraUseCase {
  double call({
    required List<PiggyBank> piggyBanks,
    required List<Invoice> openInvoices,
    required Budget? currentBudget,
    required double monthlyExpenses,
    required double goalsProgress,
    required bool incomeCoversOd,
  }) {
    double score = 0;

    // 1. Cobertura CF (30 pts)
    final cfs = piggyBanks.where((p) => p.isCaixinhaFatura).toList();
    final totalCf = cfs.fold<double>(0, (s, p) => s + p.currentBalance);
    final totalOpen = openInvoices.fold<double>(0, (s, i) => s + i.remaining);
    if (totalOpen == 0) {
      score += 30;
    } else {
      final ratio = (totalCf / totalOpen).clamp(0.0, 1.0);
      score += ratio * 30;
    }

    // 2. Reserva de Emergencia (25 pts) - meta: 3x despesas mensais
    final ces = piggyBanks.where((p) => p.isCaixinhaEmergencia).toList();
    final totalCe = ces.fold<double>(0, (s, p) => s + p.currentBalance);
    if (monthlyExpenses > 0) {
      final ratio = (totalCe / (monthlyExpenses * 3)).clamp(0.0, 1.0);
      score += ratio * 25;
    }

    // 3. Aderencia ao orcamento (20 pts)
    if (currentBudget != null && currentBudget.totalLimit > 0) {
      final overrun = currentBudget.totalSpent / currentBudget.totalLimit;
      if (overrun <= 1.0) {
        score += 20;
      } else if (overrun <= 1.2) {
        score += 10;
      }
    }

    // 4. Progresso de metas (15 pts)
    score += goalsProgress.clamp(0.0, 1.0) * 15;

    // 5. OD - renda do mes anterior cobre orcamento (10 pts)
    if (incomeCoversOd) score += 10;

    return score.clamp(0.0, 100.0);
  }
}
