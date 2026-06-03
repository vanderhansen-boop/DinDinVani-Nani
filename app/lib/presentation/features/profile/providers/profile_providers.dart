import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/remote/profile_remote_datasource.dart';
import '../../../../data/repositories/profile_repository_impl.dart';
import '../../../../domain/entities/family_settings.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/usecases/manage_profile.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

// Infra
final profileDatasourceProvider = Provider<ProfileRemoteDatasource>(
    (ref) => ProfileRemoteDatasourceImpl(Supabase.instance.client));

final profileRepositoryProvider = Provider(
    (ref) => ProfileRepositoryImpl(ref.watch(profileDatasourceProvider)));

// Use cases
final getCurrentProfileProvider = Provider(
    (ref) => GetCurrentProfile(ref.watch(profileRepositoryProvider)));
final getPartnerProfileProvider = Provider(
    (ref) => GetPartnerProfile(ref.watch(profileRepositoryProvider)));
final updateProfileProvider = Provider(
    (ref) => UpdateProfile(ref.watch(profileRepositoryProvider)));
final getFamilySettingsProvider = Provider(
    (ref) => GetFamilySettings(ref.watch(profileRepositoryProvider)));
final updateFamilySettingsProvider = Provider(
    (ref) => UpdateFamilySettings(ref.watch(profileRepositoryProvider)));
final exportBackupProvider = Provider(
    (ref) => ExportBackup(ref.watch(profileRepositoryProvider)));
final changePasswordProvider = Provider(
    (ref) => ChangePassword(ref.watch(profileRepositoryProvider)));

// Perfil atual
final currentProfileProvider =
    FutureProvider.autoDispose<UserProfile>((ref) async =>
        ref.watch(getCurrentProfileProvider).call());

// Perfil do parceiro
final partnerProfileProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(getPartnerProfileProvider).call(familyId);
});

// Configuracoes da familia
final familySettingsProvider =
    FutureProvider.autoDispose<FamilySettings>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(getFamilySettingsProvider).call(familyId);
});

// Estado reativo do tema (atualiza o app inteiro ao mudar)
final themeSettingsProvider =
    StateProvider<({AppThemeMode mode, ColorSchemeType scheme})>((ref) {
  return (
    mode:   AppThemeMode.system,
    scheme: ColorSchemeType.pink,
  );
});

// ThemeMode para MaterialApp
final themeModeProvider = Provider<ThemeMode>((ref) {
  final t = ref.watch(themeSettingsProvider);
  return AppTheme.toFlutterThemeMode(t.mode);
});

// ThemeData light
final lightThemeProvider = Provider<ThemeData>((ref) {
  final t = ref.watch(themeSettingsProvider);
  return AppTheme.light(t.scheme);
});

// ThemeData dark
final darkThemeProvider = Provider<ThemeData>((ref) {
  final t = ref.watch(themeSettingsProvider);
  return AppTheme.dark(t.scheme);
});

// Loading state para operacoes longas
final profileLoadingProvider = StateProvider<bool>((ref) => false);
final backupLoadingProvider  = StateProvider<bool>((ref) => false);
