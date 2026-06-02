import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/datasources/remote/budget_remote_datasource.dart';
import '../../../../data/repositories/budget_repository_impl.dart';
import '../../../../domain/entities/budget.dart';
import '../../../../domain/entities/family_goal.dart';
import '../../../../domain/entities/allocation_rule.dart';
import '../../../../domain/usecases/get_current_budget.dart';
import '../../../../domain/usecases/manage_goals.dart';
import '../../../../domain/usecases/manage_allocation_rule.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

// Infra
final budgetDatasourceProvider = Provider<BudgetRemoteDatasource>(
    (ref) => BudgetRemoteDatasourceImpl(Supabase.instance.client));

final budgetRepositoryProvider = Provider(
    (ref) => BudgetRepositoryImpl(ref.watch(budgetDatasourceProvider)));

// Use cases
final getCurrentBudgetProvider    = Provider((ref) => GetCurrentBudget(ref.watch(budgetRepositoryProvider)));
final manageGoalsProvider         = Provider((ref) => ManageGoals(ref.watch(budgetRepositoryProvider)));
final manageAllocationRuleProvider = Provider((ref) => ManageAllocationRule(ref.watch(budgetRepositoryProvider)));

// Orcamento atual
final currentBudgetProvider = FutureProvider.autoDispose<Budget?>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(getCurrentBudgetProvider).call(familyId);
});

// Historico de orcamentos
final budgetHistoryProvider = FutureProvider.autoDispose<List<Budget>>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(budgetRepositoryProvider).getBudgetHistory(familyId);
});

// Metas
final goalsProvider = FutureProvider.autoDispose<List<FamilyGoal>>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(manageGoalsProvider).getAll(familyId);
});

// Regra de alocacao
final allocationRuleProvider = FutureProvider.autoDispose<AllocationRule>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(manageAllocationRuleProvider).get(familyId);
});

// Metas ativas apenas
final activeGoalsProvider = Provider.autoDispose<List<FamilyGoal>>((ref) {
  return ref.watch(goalsProvider).when(
    data:    (list) => list.where((g) => g.status == GoalStatus.active).toList(),
    loading: () => [],
    error:   (_, __) => [],
  );
});

// Total necessario por mes para todas as metas
final totalMonthlyGoalRequiredProvider = Provider.autoDispose<double>((ref) {
  final goals = ref.watch(activeGoalsProvider);
  return goals.fold(0.0, (sum, g) => sum + (g.monthlyRequired ?? 0));
});