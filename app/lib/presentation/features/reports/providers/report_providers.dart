import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../domain/entities/monthly_summary.dart';
import '../../../../domain/entities/cashflow_projection.dart';

// ── Filtro de relatório ──────────────────────────────────────────────────────
enum ReportPeriod { threeMonths, sixMonths, twelveMonths }

class ReportFilter {
  final ReportPeriod period;
  final String?      categoryId;
  const ReportFilter({this.period = ReportPeriod.sixMonths, this.categoryId});

  ReportFilter copyWith({ReportPeriod? period, String? categoryId}) =>
      ReportFilter(
        period:     period     ?? this.period,
        categoryId: categoryId ?? this.categoryId,
      );

  int get months {
    switch (period) {
      case ReportPeriod.threeMonths:  return 3;
      case ReportPeriod.twelveMonths: return 12;
      default:                        return 6;
    }
  }
}

class ReportFilterNotifier extends StateNotifier<ReportFilter> {
  ReportFilterNotifier() : super(const ReportFilter());
  void setPeriod(ReportPeriod p) => state = state.copyWith(period: p);
  void setCategory(String? id)   => state = state.copyWith(categoryId: id);
  void reset()                   => state = const ReportFilter();
}

final reportFilterProvider =
    StateNotifierProvider<ReportFilterNotifier, ReportFilter>(
        (ref) => ReportFilterNotifier());

// ── Helpers ──────────────────────────────────────────────────────────────────
Future<MonthlySummary> _fetchMonth(
    dynamic client, String familyId, int month, int year) async {
  final from = '$year-${month.toString().padLeft(2, '0')}-01';
  final nextMonth = month == 12 ? 1 : month + 1;
  final nextYear  = month == 12 ? year + 1 : year;
  final to   = '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

  final res = await client
      .from('transactions')
      .select('type, amount, category_id')
      .eq('family_id', familyId)
      .gte('date', from)
      .lt('date', to);

  double income = 0, expense = 0;
  final Map<String, double> catMap = {};
  for (final row in res as List) {
    final amt = (row['amount'] as num).toDouble();
    if (row['type'] == 'income') {
      income += amt;
    } else {
      expense += amt;
      final cid = row['category_id'] as String? ?? 'outros';
      catMap[cid] = (catMap[cid] ?? 0) + amt;
    }
  }

  final breakdown = catMap.entries
      .map((e) => CategoryBreakdown(
            categoryId:    e.key,
            categoryName:  e.key,
            categoryEmoji: '📦',
            amount:        e.value,
            percentage:    expense > 0 ? e.value / expense : 0,
          ))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return MonthlySummary(
    month:      month,
    year:       year,
    income:     income,
    expense:    expense,
    byCategory: breakdown,
  );
}

// ── Providers ────────────────────────────────────────────────────────────────
final currentMonthSummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final client   = ref.watch(supabaseClientProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  final now      = DateTime.now();
  if (familyId.isEmpty) {
    return MonthlySummary(month: now.month, year: now.year, income: 0, expense: 0);
  }
  return _fetchMonth(client, familyId, now.month, now.year);
});

final monthlySummariesProvider =
    FutureProvider<List<MonthlySummary>>((ref) async {
  final client   = ref.watch(supabaseClientProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  final filter   = ref.watch(reportFilterProvider);
  if (familyId.isEmpty) return [];

  final now    = DateTime.now();
  final result = <MonthlySummary>[];
  for (int i = filter.months - 1; i >= 0; i--) {
    final dt = DateTime(now.year, now.month - i, 1);
    result.add(await _fetchMonth(client, familyId, dt.month, dt.year));
  }
  return result;
});

final cashflowProjectionsProvider =
    FutureProvider<List<CashflowProjection>>((ref) async {
  final history = await ref.watch(monthlySummariesProvider.future);
  if (history.isEmpty) return [];

  final avgInc = history.map((e) => e.income).reduce((a, b) => a + b) / history.length;
  final avgExp = history.map((e) => e.expense).reduce((a, b) => a + b) / history.length;

  final now         = DateTime.now();
  final projections = <CashflowProjection>[];
  for (int i = 1; i <= 3; i++) {
    final dt = DateTime(now.year, now.month + i, 1);
    projections.add(CashflowProjection(
      month:            dt.month,
      year:             dt.year,
      projectedIncome:  avgInc,
      projectedExpense: avgExp,
      isProjection:     true,
    ));
  }
  return projections;
});

// ── Export service ───────────────────────────────────────────────────────────
class ExportReportService {
  final List<MonthlySummary> summaries;
  ExportReportService(this.summaries);

  Future<void> pdf(String familyId, ReportFilter filter) async {
    // TODO: implementar geração de PDF real
    print('Exportando PDF: familyId=$familyId, meses=${filter.months}');
  }

  Future<void> csv(String familyId, ReportFilter filter) async {
    // TODO: implementar geração de CSV real
    print('Exportando CSV: familyId=$familyId, meses=${filter.months}');
  }
}

final exportReportProvider = Provider<ExportReportService>((ref) {
  final summaries = ref.watch(monthlySummariesProvider).asData?.value ?? [];
  return ExportReportService(summaries);
});

