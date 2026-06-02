import '../entities/piggy_bank.dart';
import '../entities/piggy_bank_contribution.dart';

abstract class PiggyBankRepository {
  Future<List<PiggyBank>>             getAll(String familyId);
  Future<PiggyBank>                   getById(String id);
  Future<PiggyBank>                   create(PiggyBank piggyBank);
  Future<PiggyBank>                   update(PiggyBank piggyBank);
  Future<void>                        delete(String id);
  Future<PiggyBank>                   deposit(String id, double amount, String description, String userId);
  Future<PiggyBank>                   withdraw(String id, double amount, String description, String userId);
  Future<List<PiggyBankContribution>> getContributions(String piggyBankId);
}