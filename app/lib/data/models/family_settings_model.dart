import '../../domain/entities/family_settings.dart';

class FamilySettingsModel extends FamilySettings {
  const FamilySettingsModel({
    required super.id,
    required super.familyId,
    required super.familyName,
    required super.familyEmoji,
    required super.themeMode,
    required super.colorScheme,
    required super.showBalanceOnHome,
    required super.enableOD,
    required super.enableCF,
    required super.enableCPI,
    required super.odMonthsDelay,
    required super.backupFreqDays,
    super.lastBackupAt,
  });

  factory FamilySettingsModel.fromJson(Map<String, dynamic> j) =>
      FamilySettingsModel(
        id:               j['id']         as String,
        familyId:         j['family_id']  as String,
        familyName:       j['family_name']  as String? ?? 'Vani & Nani',
        familyEmoji:      j['family_emoji'] as String? ?? '💑',
        themeMode:        _themeFromString(j['theme_mode'] as String?),
        colorScheme:      _schemeFromString(j['color_scheme'] as String?),
        showBalanceOnHome: j['show_balance_on_home'] as bool? ?? true,
        enableOD:         j['enable_od']  as bool? ?? true,
        enableCF:         j['enable_cf']  as bool? ?? true,
        enableCPI:        j['enable_cpi'] as bool? ?? true,
        odMonthsDelay:    j['od_months_delay']  as int? ?? 2,
        backupFreqDays:   j['backup_freq_days'] as int? ?? 7,
        lastBackupAt: j['last_backup_at'] != null
            ? DateTime.parse(j['last_backup_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'family_name':         familyName,
    'family_emoji':        familyEmoji,
    'theme_mode':          themeMode.name,
    'color_scheme':        colorScheme.name,
    'show_balance_on_home': showBalanceOnHome,
    'enable_od':           enableOD,
    'enable_cf':           enableCF,
    'enable_cpi':          enableCPI,
    'od_months_delay':     odMonthsDelay,
    'backup_freq_days':    backupFreqDays,
  };

  static AppThemeMode _themeFromString(String? s) {
    switch (s) {
      case 'light':  return AppThemeMode.light;
      case 'dark':   return AppThemeMode.dark;
      default:       return AppThemeMode.system;
    }
  }

  static ColorSchemeType _schemeFromString(String? s) {
    switch (s) {
      case 'blue':   return ColorSchemeType.blue;
      case 'green':  return ColorSchemeType.green;
      case 'purple': return ColorSchemeType.purple;
      case 'orange': return ColorSchemeType.orange;
      case 'teal':   return ColorSchemeType.teal;
      default:       return ColorSchemeType.pink;
    }
  }
}