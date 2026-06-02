import '../../domain/entities/user_profile.dart';
import '../../domain/entities/family_settings.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';
import '../models/family_settings_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource datasource;
  ProfileRepositoryImpl(this.datasource);

  @override
  Future<UserProfile>    getCurrentProfile()           => datasource.getCurrentProfile();
  @override
  Future<UserProfile>    updateProfile(UserProfile p)  => datasource.updateProfile(p as UserProfileModel);
  @override
  Future<UserProfile?>   getPartnerProfile(String fid) => datasource.getPartnerProfile(fid);
  @override
  Future<FamilySettings> getFamilySettings(String fid) => datasource.getFamilySettings(fid);
  @override
  Future<FamilySettings> updateFamilySettings(FamilySettings s) =>
      datasource.updateFamilySettings(s as FamilySettingsModel);
  @override
  Future<void>   changePassword(String cur, String next) =>
      datasource.changePassword(cur, next);
  @override
  Future<String> exportBackupJson(String fid) =>
      datasource.exportBackupJson(fid);
  @override
  Future<void>   importBackupJson(String fid, String json) async {
    // Implementação futura: restore seletivo com confirmação do usuario
    throw UnimplementedError('Import requer confirmação manual');
  }
  @override
  Future<void>   deleteAccount(String uid) async {
    throw UnimplementedError('Delete requer confirmação dupla');
  }
}