import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/currency_extension.dart';
import 'providers/report_providers.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/cashflow_projection_card.dart';
import 'widgets/summary_stat_card.dart';
import 'widgets/report_filter_bar.dart';
import 'widgets/export_buttons.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsync    = ref.watch(currentMonthSummaryProvider);
    final summariesAsync  = ref.watch(monthlySummariesProvider);
    final projectionsAsync = ref.watch(cashflowProjectionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentMonthSummaryProvider);
            ref.invalidate(monthlySummariesProvider);
            ref.invalidate(cashflowProjectionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Filtros
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text('Filtros',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey)),
                    ),
                    const ReportFilterBar(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ── KPIs do mes atual
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: currentAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erro: $e'),
                    data: (summary) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                            title: '📅 ${summary.monthFull}',
                            subtitle: 'Resumo atual'),
                        const SizedBox(height: 8),
                        SummaryStatCards(summary: summary),
                        const SizedBox(height: 12),
                        // Grafico de pizza do mes atual
                        if (summary.byCategory.isNotEmpty) ...[
                          _SectionHeader(
                              title: '🥧 Gastos por Categoria',
                              subtitle: summary.monthLabel),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CategoryPieChart(
                                  summary: summary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ── Grafico barras historico
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: summariesAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erro: $e'),
                    data: (summaries) => summaries.isEmpty
                        ? _EmptyState()
                        : Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                  title: '📊 Histórico Mensal',
                                  subtitle:
                                      '${summaries.length} meses'),
                              const SizedBox(height: 8),
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      // Legenda
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _Legend('Receita',
                                              Colors.green.shade400),
                                          const SizedBox(width: 16),
                                          _Legend('Despesa',
                                              Colors.red.shade400),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      MonthlyBarChart(data: summaries),
                                      const SizedBox(height: 16),
                                      // Tabela resumida
                                      _SummaryTable(summaries: summaries),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // ── Projecoes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: projectionsAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erro: $e'),
                    data: (projs) => CashflowProjectionCard(
                        projections: projs),
                  ),
                ),
              ),

              // ── Exportar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                          title: '📤 Exportar Relatório',
                          subtitle: 'CSV ou PDF'),
                      const SizedBox(height: 8),
                      const ExportButtons(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Widgets auxiliares
// ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(width: 6),
      Text(subtitle,
          style: TextStyle(
              fontSize: 11, color: Colors.grey.shade500)),
    ],
  );
}

class _Legend extends StatelessWidget {
  final String label;
  final Color  color;
  const _Legend(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _SummaryTable extends StatelessWidget {
  final List summaries;
  const _SummaryTable({required this.summaries});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Header
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Expanded(flex: 2,
                child: Text('Mês',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold))),
            Expanded(child: Text('Receita',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
            Expanded(child: Text('Despesa',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
            Expanded(child: Text('Saldo',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
          ],
        ),
      ),
      ...summaries.map((s) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 5),
        child: Row(
          children: [
            Expanded(flex: 2,
                child: Text(s.monthLabel,
                    style: const TextStyle(fontSize: 11))),
            Expanded(
                child: Text(s.totalIncome.toBRL,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green))),
            Expanded(
                child: Text(s.totalExpenses.toBRL,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red))),
            Expanded(
                child: Text(s.balance.toBRL,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: s.isPositive
                            ? Colors.blue
                            : Colors.orange))),
          ],
        ),
      )),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        const Text('📊',
            style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        const Text('Nenhum dado encontrado',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 6),
        Text(
          'Registre transações para visualizar\n'
          'seus relatórios financeiros.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}