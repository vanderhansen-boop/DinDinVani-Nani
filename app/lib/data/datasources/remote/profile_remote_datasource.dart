import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile_model.dart';
import '../../models/family_settings_model.dart';
import '../../../core/utils/family_guard.dart';

abstract class ProfileRemoteDatasource {
  Future<UserProfileModel>    getCurrentProfile();
  Future<UserProfileModel>    updateProfile(UserProfileModel model);
  Future<UserProfileModel?>   getPartnerProfile(String familyId);
  Future<FamilySettingsModel> getFamilySettings(String familyId);
  Future<FamilySettingsModel> updateFamilySettings(FamilySettingsModel model);
  Future<void>                changePassword(String current, String next);
  Future<String>              exportBackupJson(String familyId);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final SupabaseClient _client;
  ProfileRemoteDatasourceImpl(this._client);

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<UserProfileModel> getCurrentProfile() async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', _uid)
        .single();
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel model) async {
    // Atualiza tabela users
    final data = await _client
        .from('users')
        .update(model.toJson())
        .eq('id', _uid)
        .select()
        .single();
    // Sincroniza display_name no auth
    await _client.auth.updateUser(
        UserAttributes(data: {'name': model.name}));
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<UserProfileModel?> getPartnerProfile(String familyId) async {
    if (!isValidFamilyId(familyId)) return null;
    final data = await _client
        .from('users')
        .select()
        .eq('family_id', familyId)
        .neq('id', _uid)
        .maybeSingle();
    return data != null ? UserProfileModel.fromJson(data) : null;
  }

  @override
  Future<FamilySettingsModel> getFamilySettings(String familyId) async {
    if (!isValidFamilyId(familyId)) {
      throw StateError('family_id vazio em getFamilySettings');
    }
    final data = await _client
        .from('family_settings')
        .select()
        .eq('family_id', familyId)
        .single();
    return FamilySettingsModel.fromJson(data);
  }

  @override
  Future<FamilySettingsModel> updateFamilySettings(
      FamilySettingsModel model) async {
    final data = await _client
        .from('family_settings')
        .update(model.toJson())
        .eq('family_id', model.familyId)
        .select()
        .single();
    return FamilySettingsModel.fromJson(data);
  }

  @override
  Future<void> changePassword(String current, String next) async {
    await _client.auth.updateUser(
        UserAttributes(password: next));
  }

  @override
  Future<String> exportBackupJson(String familyId) async {
    if (!isValidFamilyId(familyId)) {
      throw StateError('family_id vazio em exportBackupJson');
    }
    // Exporta todas as tabelas relevantes da familia
    final results = await Future.wait([
      _client.from('accounts')
          .select().eq('family_id', familyId),
      _client.from('transactions')
          .select().eq('family_id', familyId),
      _client.from('piggy_banks')
          .select().eq('family_id', familyId),
      _client.from('credit_cards')
          .select().eq('family_id', familyId),
      _client.from('budgets')
          .select().eq('family_id', familyId),
      _client.from('family_goals')
          .select().eq('family_id', familyId),
    ]);

    final backup = {
      'version':     '1.0',
      'family_id':   familyId,
      'exported_at': DateTime.now().toIso8601String(),
      'accounts':    results[0],
      'transactions': results[1],
      'piggy_banks': results[2],
      'credit_cards': results[3],
      'budgets':     results[4],
      'goals':       results[5],
    };

    return jsonEncode(backup);
  }
}
