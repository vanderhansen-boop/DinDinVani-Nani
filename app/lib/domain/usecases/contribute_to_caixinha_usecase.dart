import '../repositories/i_piggy_banks_repository.dart';
import '../../core/errors/failure.dart';

class ContributeToCaixinhaUseCase {
  final IPiggyBanksRepository repo;
  ContributeToCaixinhaUseCase(this.repo);

  Future<void> call({
    required String piggyBankId,
    required double amount,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw const ValidationFailure('Valor deve ser maior que zero');
    }
    if (amount > 1000000) {
      throw const ValidationFailure('Valor excede limite por contribuicao');
    }
    return repo.contribute(piggyBankId: piggyBankId, amount: amount, userId: userId);
  }
}
