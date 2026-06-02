import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../models/goal_model.dart';

class GoalsRemoteDataSource {
  final SupabaseClient _c = SupabaseService.client;

  Future<List<GoalModel>> list(String familyId) async {
    final data = await _c
        .from('family_goals')
        .select()
        .eq('family_id', familyId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => GoalModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<GoalModel> insert(Map<String, dynamic> data) async {
    final res = await _c.from('family_goals').insert(data).select().single();
    return GoalModel.fromJson(Map<String, dynamic>.from(res));
  }
}
