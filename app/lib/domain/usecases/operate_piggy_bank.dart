import '../entities/piggy_bank.dart';
import '../entities/piggy_bank_contribution.dart';
import '../repositories/piggy_bank_repository.dart';

class OperatePiggyBank {
  final PiggyBankRepository repository;
  OperatePiggyBank(this.repository);

  Future<PiggyBank> deposit(String id, double amount, String desc, String userId) =>
      repository.deposit(id, amount, desc, userId);

  Future<PiggyBank> withdraw(String id, double amount, String desc, String userId) =>
      repository.withdraw(id, amount, desc, userId);

  Future<List<PiggyBankContribution>> getHistory(String piggyBankId) =>
      repository.getContributions(piggyBankId);
}