enum AppThemeMode { light, dark, system }
enum ColorSchemeType { pink, blue, green, purple, orange, teal }

/// Configuracoes compartilhadas do casal
class FamilySettings {
  final String          id;
  final String          familyId;
  final String          familyName;        // ex: Vani & Nani
  final String          familyEmoji;       // ex: 💑
  final AppThemeMode    themeMode;
  final ColorSchemeType colorScheme;
  final bool            showBalanceOnHome;
  final bool            enableOD;          // Orcamento Defasado ativo
  final bool            enableCF;          // Caixinha de Fatura ativa
  final bool            enableCPI;         // Caixinha Parcela Integral ativa
  final int             odMonthsDelay;     // padrao: 2
  final int             backupFreqDays;    // frequencia backup automatico
  final DateTime?       lastBackupAt;

  const FamilySettings({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.familyEmoji,
    required this.themeMode,
    required this.colorScheme,
    required this.showBalanceOnHome,
    required this.enableOD,
    required this.enableCF,
    required this.enableCPI,
    required this.odMonthsDelay,
    required this.backupFreqDays,
    this.lastBackupAt,
  });

  String get themeLabel {
    switch (themeMode) {
      case AppThemeMode.light:  return 'Claro';
      case AppThemeMode.dark:   return 'Escuro';
      case AppThemeMode.system: return 'Sistema';
    }
  }

  String get schemeLabel {
    switch (colorScheme) {
      case ColorSchemeType.pink:   return '🌸 Rosa';
      case ColorSchemeType.blue:   return '💙 Azul';
      case ColorSchemeType.green:  return '💚 Verde';
      case ColorSchemeType.purple: return '💜 Roxo';
      case ColorSchemeType.orange: return '🧡 Laranja';
      case ColorSchemeType.teal:   return '🩵 Teal';
    }
  }

  FamilySettings copyWith({
    String?          familyName,
    String?          familyEmoji,
    AppThemeMode?    themeMode,
    ColorSchemeType? colorScheme,
    bool?            showBalanceOnHome,
    bool?            enableOD,
    bool?            enableCF,
    bool?            enableCPI,
    int?             odMonthsDelay,
    int?             backupFreqDays,
    DateTime?        lastBackupAt,
  }) => FamilySettings(
    id:               id,
    familyId:         familyId,
    familyName:       familyName       ?? this.familyName,
    familyEmoji:      familyEmoji      ?? this.familyEmoji,
    themeMode:        themeMode        ?? this.themeMode,
    colorScheme:      colorScheme      ?? this.colorScheme,
    showBalanceOnHome: showBalanceOnHome ?? this.showBalanceOnHome,
    enableOD:         enableOD         ?? this.enableOD,
    enableCF:         enableCF         ?? this.enableCF,
    enableCPI:        enableCPI        ?? this.enableCPI,
    odMonthsDelay:    odMonthsDelay    ?? this.odMonthsDelay,
    backupFreqDays:   backupFreqDays   ?? this.backupFreqDays,
    lastBackupAt:     lastBackupAt     ?? this.lastBackupAt,
  );
}