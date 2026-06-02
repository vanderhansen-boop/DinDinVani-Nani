import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/piggy_bank_model.dart';
import '../../models/piggy_bank_contribution_model.dart';

abstract class PiggyBankRemoteDatasource {
  Future<List<PiggyBankModel>>             getAll(String familyId);
  Future<PiggyBankModel>                   getById(String id);
  Future<PiggyBankModel>                   create(PiggyBankModel model);
  Future<PiggyBankModel>                   update(PiggyBankModel model);
  Future<void>                             delete(String id);
  Future<PiggyBankModel>                   deposit(String id, double amount, String description, String userId);
  Future<PiggyBankModel>                   withdraw(String id, double amount, String description, String userId);
  Future<List<PiggyBankContributionModel>> getContributions(String piggyBankId);
}

class PiggyBankRemoteDatasourceImpl implements PiggyBankRemoteDatasource {
  final SupabaseClient _client;
  PiggyBankRemoteDatasourceImpl(this._client);

  @override
  Future<List<PiggyBankModel>> getAll(String familyId) async {
    final data = await _client
        .from('piggy_banks')
        .select()
        .eq('family_id', familyId)
        .eq('is_active', true)
        .order('created_at');
    return (data as List).map((e) => PiggyBankModel.fromJson(e)).toList();
  }

  @override
  Future<PiggyBankModel> getById(String id) async {
    final data = await _client
        .from('piggy_banks')
        .select()
        .eq('id', id)
        .single();
    return PiggyBankModel.fromJson(data);
  }

  @override
  Future<PiggyBankModel> create(PiggyBankModel model) async {
    final data = await _client
        .from('piggy_banks')
        .insert(model.toJson())
        .select()
        .single();
    return PiggyBankModel.fromJson(data);
  }

  @override
  Future<PiggyBankModel> update(PiggyBankModel model) async {
    final data = await _client
        .from('piggy_banks')
        .update(model.toJson())
        .eq('id', model.id)
        .select()
        .single();
    return PiggyBankModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('piggy_banks').update({'is_active': false}).eq('id', id);
  }

  @override
  Future<PiggyBankModel> deposit(
      String id, double amount, String description, String userId) async {
    // Usa RPC para garantir atomicidade: atualiza saldo + insere contribuicao
    await _client.rpc('piggy_bank_deposit', params: {
      'p_id':          id,
      'p_amount':      amount,
      'p_description': description,
      'p_user_id':     userId,
    });
    return getById(id);
  }

  @override
  Future<PiggyBankModel> withdraw(
      String id, double amount, String description, String userId) async {
    await _client.rpc('piggy_bank_withdraw', params: {
      'p_id':          id,
      'p_amount':      amount,
      'p_description': description,
      'p_user_id':     userId,
    });
    return getById(id);
  }

  @override
  Future<List<PiggyBankContributionModel>> getContributions(String piggyBankId) async {
    final data = await _client
        .from('piggy_bank_contributions')
        .select()
        .eq('piggy_bank_id', piggyBankId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((e) => PiggyBankContributionModel.fromJson(e)).toList();
  }
}