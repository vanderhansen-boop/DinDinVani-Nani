import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/remote/report_remote_datasource.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/cashflow_projection.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/cashflow_projection.dart';
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

  // ── Metodos de alto nivel (logica real nos providers Riverpod) ──
  @override
  Future<List<MonthlySummary>> getMonthlySummaries(
          String familyId, ReportFilter filter) async =>
      throw UnimplementedError(
          'getMonthlySummaries: ver report_providers.dart');

  @override
  Future<MonthlySummary> getCurrentMonthSummary(String familyId) async =>
      throw UnimplementedError(
          'getCurrentMonthSummary: ver report_providers.dart');

  @override
  Future<List<CashflowProjection>> getProjections(
          String familyId, {int months = 3}) async =>
      throw UnimplementedError(
          'getProjections: ver report_providers.dart');

  @override
  Future<String> exportCsv(String familyId, ReportFilter filter) async =>
      throw UnimplementedError('exportCsv: ver ExportReportService');

  @override
  Future<String> exportPdf(String familyId, ReportFilter filter) async =>
      throw UnimplementedError('exportPdf: ver ExportReportService');
}



