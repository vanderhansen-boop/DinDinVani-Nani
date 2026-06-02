import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

class TransactionsRemoteDataSource {
  final SupabaseClient _c = SupabaseService.client;

  Future<List<TransactionModel>> listByMonth({
    required String familyId,
    required int month,
    required int year,
  }) async {
    try {
      final start = DateTime(year, month, 1).toIso8601String();
      final end = DateTime(year, month + 1, 1).toIso8601String();
      final data = await _c
          .from('transactions')
          .select()
          .eq('family_id', familyId)
          .gte('date', start)
          .lt('date', end)
          .order('date', ascending: false);
      return (data as List)
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<TransactionModel> insert(TransactionModel t) async {
    try {
      final data = await _c.from('transactions').insert(t.toJson()).select().single();
      return TransactionModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> delete(String id) async {
    await _c.from('transactions').delete().eq('id', id);
  }

  Future<TransactionModel> update(String id, Map<String, dynamic> fields) async {
    final data = await _c.from('transactions').update(fields).eq('id', id).select().single();
    return TransactionModel.fromJson(Map<String, dynamic>.from(data));
  }

  Stream<List<TransactionModel>> watchByFamily(String familyId) {
    return _c
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId)
        .order('date', ascending: false)
        .map((List<Map<String, dynamic>> rows) =>
            rows.map((Map<String, dynamic> e) => TransactionModel.fromJson(e)).toList());
  }
}
