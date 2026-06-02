import '../entities/piggy_bank.dart';
import '../repositories/piggy_bank_repository.dart';

class SavePiggyBank {
  final PiggyBankRepository repository;
  SavePiggyBank(this.repository);

  Future<PiggyBank> create(PiggyBank p)   => repository.create(p);
  Future<PiggyBank> update(PiggyBank p)   => repository.update(p);
  Future<void>      delete(String id)     => repository.delete(id);
}