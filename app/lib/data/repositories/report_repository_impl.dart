import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/remote/report_remote_datasource.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _datasource;
  ReportRepositoryImpl(this._datasource);

  @override
  Future<List<Map<String, dynamic>>> getTransactions({
    required String familyId,
    required ReportFilter filter,
  }) => _datasource.getTransactions(familyId: familyId, filter: filter);

  @override
  Future<Map<String, dynamic>> getSummary({
    required String familyId,
    required ReportFilter filter,
  }) => _datasource.getSummary(familyId: familyId, filter: filter);

  @override
  Future<List<Map<String, dynamic>>> getByCategory({
    required String familyId,
    required ReportFilter filter,
  }) => _datasource.getByCategory(familyId: familyId, filter: filter);
}
