import '../entities/budget.dart';

abstract class IBudgetsRepository {
  Future<Budget?> getCurrent(String familyId);
  Future<List<Budget>> listHistory(String familyId, {int limit});
}
