import '../entities/goal.dart';

abstract class IGoalsRepository {
  Future<List<Goal>> list(String familyId);
  Future<Goal> create(Map<String, dynamic> data);
}
