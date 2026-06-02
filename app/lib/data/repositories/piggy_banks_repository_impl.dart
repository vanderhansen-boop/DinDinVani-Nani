import '../datasources/piggy_banks_remote_datasource.dart';
import '../models/piggy_bank_model.dart';
import '../../core/errors/failure.dart';

class PiggyBanksRepositoryImpl {
  final PiggyBanksRemoteDataSource remote;
  PiggyBanksRepositoryImpl(this.remote);

  Future<List<PiggyBankModel>> list(String familyId) => remote.list(familyId);

  Future<PiggyBankModel> create(PiggyBankModel p) async {
    const validTypes = ['CF', 'CPI', 'CP', 'CM', 'CE'];
    if (!validTypes.contains(p.type)) {
      throw ValidationFailure('Tipo de caixinha invalido: ${p.type}');
    }
    if (p.type == 'CF' && p.creditCardId == null) {
      throw const BusinessRuleFailure('Caixinha de Fatura precisa de cartao vinculado');
    }
    return remote.insert(p);
  }

  Future<void> contribute({
    required String piggyBankId,
    required double amount,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw const ValidationFailure('Valor da contribuicao deve ser maior que zero');
    }
    return remote.contribute(piggyBankId: piggyBankId, amount: amount, userId: userId);
  }

  Stream<List<PiggyBankModel>> watch(String familyId) => remote.watch(familyId);
}
