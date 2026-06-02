import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/dashboard_summary.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/summary_cards.dart';
import 'widgets/monthly_chart.dart';
import 'widgets/peace_score_card.dart';
import 'widgets/alerts_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DinDin Vani & Nani 💑'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardSummaryProvider),
          ),
        ],
      ),
      body: asyncSummary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Erro: $e'),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardSummaryProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PeaceScoreCard(score: summary.peaceScore),
              const SizedBox(height: 12),
              SummaryCards(summary: summary),
              const SizedBox(height: 12),
              if (summary.alerts.isNotEmpty) ...[
                AlertsCard(alerts: summary.alerts),
                const SizedBox(height: 12),
              ],
              if (summary.monthlyEvolution.isNotEmpty) ...[
                MonthlyChart(data: summary.monthlyEvolution),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
