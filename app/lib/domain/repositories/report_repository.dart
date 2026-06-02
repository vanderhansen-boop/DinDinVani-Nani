import '../entities/report_filter.dart';

abstract class ReportRepository {
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
}
