import '../entities/invoice.dart';
import '../entities/piggy_bank.dart';
import '../../core/errors/failure.dart';

/// Use Case - Pagamento da fatura usando a CF (Caixinha de Fatura)
/// REGRA CF: A CF do cartao paga automaticamente a fatura no vencimento.
class PayInvoiceUseCase {
  /// Valida se ha cobertura suficiente na CF
  bool hasCoverage({
    required Invoice invoice,
    required PiggyBank cf,
  }) {
    if (!cf.isCaixinhaFatura) {
      throw const BusinessRuleFailure('Caixinha precisa ser do tipo CF');
    }
    return cf.currentBalance >= invoice.remainingAmount;
  }

  /// Percentual de cobertura 0.0-1.0
  double coverageRatio({
    required Invoice invoice,
    required PiggyBank cf,
  }) {
    if (invoice.remainingAmount == 0) return 1.0;
    final r = cf.currentBalance / invoice.remainingAmount;
    return r > 1.0 ? 1.0 : r;
  }
}
