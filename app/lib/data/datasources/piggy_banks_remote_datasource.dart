import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/piggy_bank_model.dart';

class PiggyBanksRemoteDataSource {
  final SupabaseClient _c = SupabaseService.client;

  Future<List<PiggyBankModel>> list(String familyId) async {
    try {
      final data = await _c
          .from('piggy_banks')
          .select()
          .eq('family_id', familyId)
          .order('type')
          .order('name');
      return (data as List)
          .map((e) => PiggyBankModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PiggyBankModel> insert(PiggyBankModel p) async {
    final data = await _c.from('piggy_banks').insert(p.toJson()).select().single();
    return PiggyBankModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> contribute({
    required String piggyBankId,
    required double amount,
    required String userId,
  }) async {
    await _c.from('piggy_bank_contributions').insert({
      'piggy_bank_id': piggyBankId,
      'amount': amount,
      'user_id': userId,
    });
  }

  Stream<List<PiggyBankModel>> watch(String familyId) {
    return _c
        .from('piggy_banks')
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId)
        .map((List<Map<String, dynamic>> rows) =>
            rows.map((Map<String, dynamic> e) => PiggyBankModel.fromJson(e)).toList());
  }
}
