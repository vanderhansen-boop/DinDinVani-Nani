import '../entities/piggy_bank.dart';

abstract class IPiggyBanksRepository {
  Future<List<PiggyBank>> list(String familyId);
  Future<PiggyBank> create(PiggyBank piggyBank);
  Future<void> contribute({
    required String piggyBankId,
    required double amount,
    required String userId,
  });
  Stream<List<PiggyBank>> watch(String familyId);
}
