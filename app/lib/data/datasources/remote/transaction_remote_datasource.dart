// lib/data/datasources/remote/transaction_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/transaction.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../../core/utils/family_guard.dart';

abstract class TransactionRemoteDatasource {
  Future<List<TransactionModel>> getByMonth(String familyId, int year, int month);
  Future<List<TransactionModel>> getByFilter({
    required String  familyId,
    DateTime?        from,
    DateTime?        to,
    String?          categoryId,
    TransactionType? type,
    String?          search,
  });
  Future<TransactionModel> create(TransactionModel model);
  Future<TransactionModel> update(TransactionModel model);
  Future<void>             delete(String id);
  Future<List<CategoryModel>> getCategories(String familyId);
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final SupabaseClient _client;
  TransactionRemoteDatasourceImpl(this._client);

  @override
  Future<List<TransactionModel>> getByMonth(
      String familyId, int year, int month) async {
    if (!isValidFamilyId(familyId)) return [];
    final start = DateTime(year, month, 1).toIso8601String();
    final end   = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    final data  = await _client
        .from('transactions')
        .select()
        .eq('family_id', familyId)
        .gte('date', start)
        .lte('date', end)
        .order('date', ascending: false);
    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  @override
  Future<List<TransactionModel>> getByFilter({
    required String  familyId,
    DateTime?        from,
    DateTime?        to,
    String?          categoryId,
    TransactionType? type,
    String?          search,
  }) async {
    if (!isValidFamilyId(familyId)) return [];
    var query = _client
        .from('transactions')
        .select()
        .eq('family_id', familyId);

    if (from != null)       query = query.gte('date', from.toIso8601String());
    if (to   != null)       query = query.lte('date', to.toIso8601String());
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (type != null)       query = query.eq('type', type.name);
    if (search != null && search.isNotEmpty) {
      query = query.ilike('description', '%$search%');
    }

    final data = await query.order('date', ascending: false);
    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  @override
  Future<TransactionModel> create(TransactionModel model) async {
    final data = await _client
        .from('transactions')
        .insert(model.toJson())
        .select()
        .single();
    return TransactionModel.fromJson(data);
  }

  @override
  Future<TransactionModel> update(TransactionModel model) async {
    final data = await _client
        .from('transactions')
        .update(model.toJson())
        .eq('id', model.id)
        .select()
        .single();
    return TransactionModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  @override
  Future<List<CategoryModel>> getCategories(String familyId) async {
    final data = await _client
        .from('categories')
        .select()
        .or('family_id.eq.$familyId,is_default.eq.true')
        .order('name');
    return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }
}
