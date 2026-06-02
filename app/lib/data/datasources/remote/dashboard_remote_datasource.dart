// lib/data/datasources/remote/dashboard_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/dashboard_summary_model.dart';
import '../../../domain/entities/monthly_data.dart';

abstract class DashboardRemoteDatasource {
  Future<DashboardSummaryModel> getSummary(String familyId);
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final SupabaseClient _client;
  DashboardRemoteDatasourceImpl(this._client);

  @override
  Future<DashboardSummaryModel> getSummary(String familyId) async {
    try {
      // Saldo total das contas
      final accounts = await _client
          .from('accounts')
          .select('balance')
          .eq('family_id', familyId);

      final totalBalance = (accounts as List)
          .fold<double>(0, (sum, a) => sum + ((a['balance'] as num?)?.toDouble() ?? 0));

      // Transacoes do mes atual
      final now   = DateTime.now();
      final start = DateTime(now.year, now.month, 1).toIso8601String();
      final end   = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

      final txs = await _client
          .from('transactions')
          .select('amount, type')
          .eq('family_id', familyId)
          .gte('date', start)
          .lte('date', end);

      double income  = 0;
      double expense = 0;
      for (final t in (txs as List)) {
        final v = (t['amount'] as num?)?.toDouble() ?? 0;
        if (t['type'] == 'income')  income  += v;
        if (t['type'] == 'expense') expense += v;
      }

      // Caixinhas
      final piggyData = await _client
          .from('piggy_banks')
          .select('current_amount')
          .eq('family_id', familyId);

      final piggyTotal = (piggyData as List)
          .fold<double>(0, (sum, p) => sum + ((p['current_amount'] as num?)?.toDouble() ?? 0));

      // Cobertura de faturas (CF)
      final cfData = await _client
          .from('piggy_banks')
          .select('current_amount, target_amount')
          .eq('family_id', familyId)
          .eq('type', 'invoice');

      double cfCurrent = 0, cfTarget = 0;
      for (final c in (cfData as List)) {
        cfCurrent += (c['current_amount'] as num?)?.toDouble() ?? 0;
        cfTarget  += (c['target_amount']  as num?)?.toDouble() ?? 0;
      }
      final coverage = cfTarget > 0 ? (cfCurrent / cfTarget * 100) : 100.0;

      // Score Paz Financeira (simplificado)
      int score = 100;
      if (expense > income)  score -= 30;
      if (coverage < 80)     score -= 20;
      if (totalBalance <= 0) score -= 25;
      if (piggyTotal <= 0)   score -= 10;
      if (score < 0) score = 0;

      // Alertas
      final alerts = <String>[];
      if (coverage < 80)    alerts.add('Caixinha de Fatura abaixo de 80%');
      if (expense > income) alerts.add('Gastos superaram a renda este mes');
      if (totalBalance < 0) alerts.add('Saldo negativo — atenção!');

      // Evolucao dos ultimos 6 meses
      final evolution = <MonthlyData>[];
      final months = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
      for (int i = 5; i >= 0; i--) {
        final d  = DateTime(now.year, now.month - i, 1);
        final ms = DateTime(d.year, d.month, 1).toIso8601String();
        final me = DateTime(d.year, d.month + 1, 0, 23, 59, 59).toIso8601String();

        final mt = await _client
            .from('transactions')
            .select('amount, type')
            .eq('family_id', familyId)
            .gte('date', ms)
            .lte('date', me);

        double mi = 0, mx = 0;
        for (final t in (mt as List)) {
          final v = (t['amount'] as num?)?.toDouble() ?? 0;
          if (t['type'] == 'income')  mi += v;
          if (t['type'] == 'expense') mx += v;
        }
        evolution.add(MonthlyData(month: months[d.month - 1], income: mi, expense: mx));
      }

      return DashboardSummaryModel(
        totalBalance:    totalBalance,
        monthIncome:     income,
        monthExpense:    expense,
        piggyBanksTotal: piggyTotal,
        invoiceCoverage: coverage,
        peaceScore:      score,
        alerts:          alerts,
        monthlyEvolution: evolution,
      );
    } catch (e) {
      return DashboardSummaryModel.empty();
    }
  }
}
