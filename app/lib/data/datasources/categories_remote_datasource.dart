import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../models/category_model.dart';

class CategoriesRemoteDataSource {
  final SupabaseClient _c = SupabaseService.client;

  Future<List<CategoryModel>> list(String familyId) async {
    final data = await _c
        .from('categories')
        .select()
        .or('family_id.eq.$familyId,is_default.eq.true')
        .order('type')
        .order('name');
    return (data as List)
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
