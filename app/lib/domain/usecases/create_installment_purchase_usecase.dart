import '../entities/transaction.dart';
import '../entities/piggy_bank.dart';
import '../repositories/i_transactions_repository.dart';
import '../repositories/i_piggy_banks_repository.dart';
import '../../core/errors/failure.dart';

/// Use Case — Compra Parcelada (CPI - Caixinha de Parcela Integral)
/// REGRA CPI: Compra parcelada reserva o VALOR TOTAL no ato em uma CPI.
/// As parcelas sao pagas mes a mes pela CF do cartao.
class CreateInstallmentPurchaseUseCase {
  final ITransactionsRepository transactionsRepo;
  final IPiggyBanksRepository piggyBanksRepo;

  CreateInstallmentPurchaseUseCase({
    required this.transactionsRepo,
    required this.piggyBanksRepo,
  });

  Future<void> call({
    required String familyId,
    required String userId,
    required String accountId,
    required String creditCardId,
    required String description,
    required double totalAmount,
    required int installments,
    required DateTime purchaseDate,
    required String categoryId,
  }) async {
    if (totalAmount <= 0) {
      throw const ValidationFailure('Valor total deve ser maior que zero');
    }
    if (installments < 2) {
      throw const ValidationFailure('Parcelado precisa ter ao menos 2 parcelas');
    }
    if (installments > 60) {
      throw const ValidationFailure('Maximo 60 parcelas');
    }

    // 1. Cria CPI com valor TOTAL ja reservado (regra CPI)
    final cpi = PiggyBank(
      id: '',
      familyId: familyId,
      name: 'CPI: $description',
      emoji: '🛒',
      type: PiggyBankType.installment,
      currentBalance: totalAmount,
      targetAmount: totalAmount,
      isActive: true,
      creditCardId: creditCardId,
      color: '#FF9800',
    );
    await piggyBanksRepo.create(cpi);

    // 2. Cria transacao-pai (compra original parcelada)
    final parent = Transaction(
      id: '',
      familyId: familyId,
      accountId: accountId,
      creditCardId: creditCardId,
      categoryId: categoryId,
      description: description,
      amount: totalAmount,
      type: TransactionType.expense,
      date: purchaseDate,
      isPaid: false,
      recurrence: RecurrenceType.none,
      installments: installments,
      currentInstallment: 0,
      createdBy: userId,
    );
    await transactionsRepo.create(parent);

    // Obs: as parcelas individuais sao geradas pelo trigger no banco
    // (Script 14 - create_triggers)
  }
}
