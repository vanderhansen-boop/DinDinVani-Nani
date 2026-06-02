import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/budget_model.dart';
import '../../models/family_goal_model.dart';
import '../../../domain/entities/allocation_rule.dart';

abstract class BudgetRemoteDatasource {
  Future<BudgetModel?>          getBudgetForMonth(String familyId, int year, int month);
  Future<List<BudgetModel>>     getBudgetHistory(String familyId, {int limit});
  Future<BudgetModel>           createOrUpdateBudget(BudgetModel model);
  Future<List<FamilyGoalModel>> getGoals(String familyId);
  Future<FamilyGoalModel>       createGoal(FamilyGoalModel model);
  Future<FamilyGoalModel>       updateGoal(FamilyGoalModel model);
  Future<void>                  deleteGoal(String id);
  Future<AllocationRule>        getAllocationRule(String familyId);
  Future<void>                  saveAllocationRule(String familyId, AllocationRule rule);
}

class BudgetRemoteDatasourceImpl implements BudgetRemoteDatasource {
  final SupabaseClient _client;
  BudgetRemoteDatasourceImpl(this._client);

  @override
  Future<BudgetModel?> getBudgetForMonth(
      String familyId, int year, int month) async {
    final data = await _client
        .from('monthly_budgets')
        .select()
        .eq('family_id', familyId)
        .eq('budget_year', year)
        .eq('budget_month', month)
        .maybeSingle();
    return data != null ? BudgetModel.fromJson(data) : null;
  }

  @override
  Future<List<BudgetModel>> getBudgetHistory(String familyId,
      {int limit = 12}) async {
    final data = await _client
        .from('monthly_budgets')
        .select()
        .eq('family_id', familyId)
        .order('budget_year', ascending: false)
        .order('budget_month', ascending: false)
        .limit(limit);
    return (data as List).map((e) => BudgetModel.fromJson(e)).toList();
  }

  @override
  Future<BudgetModel> createOrUpdateBudget(BudgetModel model) async {
    final json = model.toJson();
    final Map<String, dynamic> data;
    if (model.id.isEmpty) {
      data = await _client
          .from('monthly_budgets')
          .insert(json)
          .select()
          .single();
    } else {
      data = await _client
          .from('monthly_budgets')
          .update(json)
          .eq('id', model.id)
          .select()
          .single();
    }
    return BudgetModel.fromJson(data);
  }

  @override
  Future<List<FamilyGoalModel>> getGoals(String familyId) async {
    final data = await _client
        .from('family_goals')
        .select()
        .eq('family_id', familyId)
        .neq('status', 'cancelled')
        .order('priority')
        .order('created_at');
    return (data as List).map((e) => FamilyGoalModel.fromJson(e)).toList();
  }

  @override
  Future<FamilyGoalModel> createGoal(FamilyGoalModel model) async {
    final data = await _client
        .from('family_goals')
        .insert(model.toJson())
        .select()
        .single();
    return FamilyGoalModel.fromJson(data);
  }

  @override
  Future<FamilyGoalModel> updateGoal(FamilyGoalModel model) async {
    final data = await _client
        .from('family_goals')
        .update(model.toJson())
        .eq('id', model.id)
        .select()
        .single();
    return FamilyGoalModel.fromJson(data);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _client
        .from('family_goals')
        .update({'status': 'cancelled'})
        .eq('id', id);
  }

  @override
  Future<AllocationRule> getAllocationRule(String familyId) async {
    final data = await _client
        .from('family_settings')
        .select('allocation_essentials, allocation_wants, allocation_savings')
        .eq('family_id', familyId)
        .maybeSingle();
    if (data == null) return AllocationRule.defaultRule;
    return AllocationRule(
      essentialsPercent: (data['allocation_essentials'] as num?)?.toDouble() ?? 50,
      wantsPercent:      (data['allocation_wants']      as num?)?.toDouble() ?? 30,
      savingsPercent:    (data['allocation_savings']    as num?)?.toDouble() ?? 20,
    );
  }

  @override
  Future<void> saveAllocationRule(String familyId, AllocationRule rule) async {
    await _client.from('family_settings').upsert({
      'family_id':             familyId,
      'allocation_essentials': rule.essentialsPercent,
      'allocation_wants':      rule.wantsPercent,
      'allocation_savings':    rule.savingsPercent,
    }, onConflict: 'family_id');
  }
}