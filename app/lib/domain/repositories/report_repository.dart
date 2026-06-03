import '../entities/report_filter.dart';
import '../entities/monthly_summary.dart';
import '../entities/cashflow_projection.dart';

abstract class ReportRepository {
  // ── Dados crus (legacy) ─────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTransactions({
    required String familyId,
    required ReportFilter filter,
  });

  Future<Map<String, dynamic>> getSummary({
    required String familyId,
    required ReportFilter filter,
  });

  Future<List<Map<String, dynamic>>> getByCategory({
    required String familyId,
    required ReportFilter filter,
  });

  // ── Entidades de alto nivel (usadas pelos use cases) ────────
  Future<List<MonthlySummary>> getMonthlySummaries(
      String familyId, ReportFilter filter);

  Future<MonthlySummary> getCurrentMonthSummary(String familyId);

  Future<List<CashflowProjection>> getProjections(
      String familyId, {int months = 3});

  Future<String> exportCsv(String familyId, ReportFilter filter);
  Future<String> exportPdf(String familyId, ReportFilter filter);
}
