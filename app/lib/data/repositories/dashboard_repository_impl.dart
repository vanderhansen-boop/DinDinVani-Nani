import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/remote/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _datasource;
  DashboardRepositoryImpl(this._datasource);

  @override
  Future<DashboardSummary> getSummary(String familyId) =>
      _datasource.getSummary(familyId);
}
