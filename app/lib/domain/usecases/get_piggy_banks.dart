import '../entities/piggy_bank.dart';
import '../repositories/piggy_bank_repository.dart';

class GetPiggyBanks {
  final PiggyBankRepository repository;
  GetPiggyBanks(this.repository);

  Future<List<PiggyBank>> call(String familyId) =>
      repository.getAll(familyId);
}