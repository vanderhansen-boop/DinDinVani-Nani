import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummary {
  final DashboardRepository _repository;
  const GetDashboardSummary(this._repository);

  Future<DashboardSummary> call(String familyId) =>
      _repository.getSummary(familyId);
}
