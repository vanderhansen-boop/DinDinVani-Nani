/// Perfil completo de um usuario do casal
class UserProfile {
  final String  id;
  final String  familyId;
  final String  name;
  final String  email;
  final String? avatarUrl;
  final String  emoji;       // avatar emoji escolhido
  final String  role;        // vani | nani | admin
  final bool    notificationsEnabled;
  final String  currency;    // BRL
  final String  locale;      // pt_BR
  final DateTime createdAt;
  final DateTime? lastSeenAt;

  const UserProfile({
    required this.id,
    required this.familyId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.emoji,
    required this.role,
    required this.notificationsEnabled,
    required this.currency,
    required this.locale,
    required this.createdAt,
    this.lastSeenAt,
  });

  String get displayName => name.split(' ').first;
  bool   get isVani      => role == 'vani';
  bool   get isNani      => role == 'nani';

  UserProfile copyWith({
    String?  name,
    String?  avatarUrl,
    String?  emoji,
    bool?    notificationsEnabled,
  }) => UserProfile(
    id:                    id,
    familyId:              familyId,
    name:                  name  ?? this.name,
    email:                 email,
    avatarUrl:             avatarUrl ?? this.avatarUrl,
    emoji:                 emoji ?? this.emoji,
    role:                  role,
    notificationsEnabled:  notificationsEnabled ?? this.notificationsEnabled,
    currency:              currency,
    locale:                locale,
    createdAt:             createdAt,
    lastSeenAt:            lastSeenAt,
  );
}