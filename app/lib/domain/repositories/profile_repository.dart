import '../entities/user_profile.dart';
import '../entities/family_settings.dart';

abstract class ProfileRepository {
  Future<UserProfile>     getCurrentProfile();
  Future<UserProfile>     updateProfile(UserProfile profile);
  Future<UserProfile?>    getPartnerProfile(String familyId);
  Future<FamilySettings>  getFamilySettings(String familyId);
  Future<FamilySettings>  updateFamilySettings(FamilySettings settings);
  Future<void>            changePassword(String currentPwd, String newPwd);
  Future<String>          exportBackupJson(String familyId);
  Future<void>            importBackupJson(String familyId, String json);
  Future<void>            deleteAccount(String userId);
}