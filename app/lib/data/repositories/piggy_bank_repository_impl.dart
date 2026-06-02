import '../../domain/entities/piggy_bank.dart';
import '../../domain/entities/piggy_bank_contribution.dart';
import '../../domain/repositories/piggy_bank_repository.dart';
import '../datasources/remote/piggy_bank_remote_datasource.dart';
import '../models/piggy_bank_model.dart';

class PiggyBankRepositoryImpl implements PiggyBankRepository {
  final PiggyBankRemoteDatasource datasource;
  PiggyBankRepositoryImpl(this.datasource);

  @override Future<List<PiggyBank>> getAll(String familyId) => datasource.getAll(familyId);
  @override Future<PiggyBank>       getById(String id)      => datasource.getById(id);

  @override
  Future<PiggyBank> create(PiggyBank p) =>
      datasource.create(PiggyBankModel(
        id: '', familyId: p.familyId, name: p.name, emoji: p.emoji,
        type: p.type, currentBalance: p.currentBalance, targetAmount: p.targetAmount,
        targetDate: p.targetDate, isActive: p.isActive,
        creditCardId: p.creditCardId, color: p.color,
      ));

  @override
  Future<PiggyBank> update(PiggyBank p) =>
      datasource.update(p as PiggyBankModel);

  @override Future<void>      delete(String id)                                          => datasource.delete(id);
  @override Future<PiggyBank> deposit(String id, double a, String d, String u)          => datasource.deposit(id, a, d, u);
  @override Future<PiggyBank> withdraw(String id, double a, String d, String u)         => datasource.withdraw(id, a, d, u);
  @override Future<List<PiggyBankContribution>> getContributions(String piggyBankId)    => datasource.getContributions(piggyBankId);
}