import '../entities/user_profile.dart';
import '../entities/family_settings.dart';
import '../repositories/profile_repository.dart';

class GetCurrentProfile {
  final ProfileRepository repository;
  GetCurrentProfile(this.repository);
  Future<UserProfile> call() => repository.getCurrentProfile();
}

class GetPartnerProfile {
  final ProfileRepository repository;
  GetPartnerProfile(this.repository);
  Future<UserProfile?> call(String familyId) =>
      repository.getPartnerProfile(familyId);
}

class UpdateProfile {
  final ProfileRepository repository;
  UpdateProfile(this.repository);
  Future<UserProfile> call(UserProfile profile) =>
      repository.updateProfile(profile);
}

class GetFamilySettings {
  final ProfileRepository repository;
  GetFamilySettings(this.repository);
  Future<FamilySettings> call(String familyId) =>
      repository.getFamilySettings(familyId);
}

class UpdateFamilySettings {
  final ProfileRepository repository;
  UpdateFamilySettings(this.repository);
  Future<FamilySettings> call(FamilySettings settings) =>
      repository.updateFamilySettings(settings);
}

class ExportBackup {
  final ProfileRepository repository;
  ExportBackup(this.repository);
  Future<String> call(String familyId) =>
      repository.exportBackupJson(familyId);
}

class ChangePassword {
  final ProfileRepository repository;
  ChangePassword(this.repository);
  Future<void> call(String current, String next) =>
      repository.changePassword(current, next);
}