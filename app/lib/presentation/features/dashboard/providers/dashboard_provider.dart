import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/remote/dashboard_remote_datasource.dart';
import '../../../../data/repositories/dashboard_repository_impl.dart';
import '../../../../domain/entities/dashboard_summary.dart';
import '../../../../domain/usecases/get_dashboard_summary.dart';
import '../../../../core/providers/supabase_provider.dart';

// Provider do datasource
final dashboardDatasourceProvider = Provider<DashboardRemoteDatasource>(
  (ref) => DashboardRemoteDatasourceImpl(ref.watch(supabaseClientProvider)),
);

// Provider do repositorio
final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>(
  (ref) => DashboardRepositoryImpl(ref.watch(dashboardDatasourceProvider)),
);

// Provider do use case
final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummary>(
  (ref) => GetDashboardSummary(ref.watch(dashboardRepositoryProvider)),
);

// Provider de estado do dashboard
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>(
  (ref) async {
    // CORRIGIDO: le do provider correto (tabela users via AuthAuthenticated),
    // NAO mais de userMetadata (que vinha vazio -> uuid: "").
    final familyId = ref.watch(currentFamilyIdProvider);

    if (familyId.isEmpty) {
      return const DashboardSummary(
        totalBalance:    0,
        monthIncome:     0,
        monthExpense:    0,
        piggyBanksTotal: 0,
        invoiceCoverage: 0,
        peaceScore:      0,
        alerts:          [],
        monthlyEvolution:[],
      );
    }

    final useCase = ref.watch(getDashboardSummaryUseCaseProvider);
    return useCase.call(familyId);
  },
);
