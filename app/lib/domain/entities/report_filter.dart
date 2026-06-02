enum ReportPeriod { last3months, last6months, last12months, custom }
enum ReportGroupBy { category, month, user, paymentMethod }

class ReportFilter {
  final ReportPeriod  period;
  final DateTime?     startDate;
  final DateTime?     endDate;
  final ReportGroupBy groupBy;
  final List<String>  categoryIds;  // vazio = todas
  final String?       userId;       // nulo = todos

  const ReportFilter({
    this.period      = ReportPeriod.last3months,
    this.startDate,
    this.endDate,
    this.groupBy     = ReportGroupBy.category,
    this.categoryIds = const [],
    this.userId,
  });

  ReportFilter copyWith({
    ReportPeriod?  period,
    DateTime?      startDate,
    DateTime?      endDate,
    ReportGroupBy? groupBy,
    List<String>?  categoryIds,
    String?        userId,
  }) => ReportFilter(
    period:      period      ?? this.period,
    startDate:   startDate   ?? this.startDate,
    endDate:     endDate     ?? this.endDate,
    groupBy:     groupBy     ?? this.groupBy,
    categoryIds: categoryIds ?? this.categoryIds,
    userId:      userId      ?? this.userId,
  );

  DateTime get resolvedStart {
    if (startDate != null) return startDate!;
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.last3months:  return DateTime(now.year, now.month - 3, 1);
      case ReportPeriod.last6months:  return DateTime(now.year, now.month - 6, 1);
      case ReportPeriod.last12months: return DateTime(now.year, now.month - 12, 1);
      default: return DateTime(now.year, now.month - 3, 1);
    }
  }

  DateTime get resolvedEnd => endDate ?? DateTime.now();

  String get periodLabel {
    switch (period) {
      case ReportPeriod.last3months:  return 'Últimos 3 meses';
      case ReportPeriod.last6months:  return 'Últimos 6 meses';
      case ReportPeriod.last12months: return 'Último ano';
      case ReportPeriod.custom:       return 'Personalizado';
    }
  }
}