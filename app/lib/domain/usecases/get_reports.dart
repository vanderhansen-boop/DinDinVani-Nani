import '../entities/monthly_summary.dart';
import '../entities/cashflow_projection.dart';
import '../entities/report_filter.dart';
import '../repositories/report_repository.dart';

class GetMonthlySummaries {
  final ReportRepository repository;
  GetMonthlySummaries(this.repository);

  Future<List<MonthlySummary>> call(String familyId, ReportFilter filter) =>
      repository.getMonthlySummaries(familyId, filter);
}

class GetCurrentMonthSummary {
  final ReportRepository repository;
  GetCurrentMonthSummary(this.repository);

  Future<MonthlySummary> call(String familyId) =>
      repository.getCurrentMonthSummary(familyId);
}

class GetCashflowProjections {
  final ReportRepository repository;
  GetCashflowProjections(this.repository);

  Future<List<CashflowProjection>> call(String familyId, {int months = 3}) =>
      repository.getProjections(familyId, months: months);
}

class ExportReport {
  final ReportRepository repository;
  ExportReport(this.repository);

  Future<String> csv(String familyId, ReportFilter filter) =>
      repository.exportCsv(familyId, filter);

  Future<String> pdf(String familyId, ReportFilter filter) =>
      repository.exportPdf(familyId, filter);
}