import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../models/budget_model.dart';

class BudgetsRemoteDataSource {
  final SupabaseClient _c = SupabaseService.client;

  Future<BudgetModel?> getCurrent(String familyId) async {
    final now = DateTime.now();
    final data = await _c
        .from('monthly_budgets')
        .select()
        .eq('family_id', familyId)
        .eq('reference_month', now.month)
        .eq('reference_year', now.year)
        .maybeSingle();
    if (data == null) return null;
    return BudgetModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<BudgetModel>> listHistory(String familyId, {int limit = 12}) async {
    final data = await _c
        .from('monthly_budgets')
        .select()
        .eq('family_id', familyId)
        .order('reference_year', ascending: false)
        .order('reference_month', ascending: false)
        .limit(limit);
    return (data as List)
        .map((e) => BudgetModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
