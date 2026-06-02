import '../entities/transaction.dart';
import '../repositories/i_transactions_repository.dart';
import '../repositories/i_piggy_banks_repository.dart';
import '../../core/errors/failure.dart';

/// Use Case - Criar transacao com regras CF aplicadas
/// REGRA CF: Toda despesa em cartao de credito reserva o valor
/// imediatamente na Caixinha de Fatura do cartao.
class CreateTransactionUseCase {
  final ITransactionsRepository transactionsRepo;
  final IPiggyBanksRepository piggyBanksRepo;

  CreateTransactionUseCase({
    required this.transactionsRepo,
    required this.piggyBanksRepo,
  });

  Future<Transaction> call(Transaction t) async {
    if (t.amount <= 0) {
      throw const ValidationFailure('Valor deve ser maior que zero');
    }
    if (t.description.trim().isEmpty) {
      throw const ValidationFailure('Descricao obrigatoria');
    }

    // A reserva CF e feita por trigger no banco (Script 14)
    // Aqui apenas garantimos a integridade dos dados
    if (t.isCreditCardExpense && t.creditCardId == null) {
      throw const BusinessRuleFailure('Despesa de cartao precisa de credit_card_id');
    }

    return transactionsRepo.create(t);
  }
}
