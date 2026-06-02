import '../datasources/goals_remote_datasource.dart';
import '../models/goal_model.dart';
import '../../core/errors/failure.dart';

class GoalsRepositoryImpl {
  final GoalsRemoteDataSource remote;
  GoalsRepositoryImpl(this.remote);

  Future<List<GoalModel>> list(String familyId) => remote.list(familyId);

  Future<GoalModel> create({
    required String familyId,
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
  }) async {
    if (targetAmount <= 0) {
      throw const ValidationFailure('Valor da meta deve ser maior que zero');
    }
    return remote.insert({
      'family_id': familyId,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': 0,
      'target_date': targetDate?.toIso8601String(),
      'icon': icon,
      'status': 'active',
    });
  }
}
