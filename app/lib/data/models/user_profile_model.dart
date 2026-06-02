import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.familyId,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.emoji,
    required super.role,
    required super.notificationsEnabled,
    required super.currency,
    required super.locale,
    required super.createdAt,
    super.lastSeenAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> j) =>
      UserProfileModel(
        id:                   j['id']    as String,
        familyId:             j['family_id'] as String,
        name:                 j['name']  as String? ?? '',
        email:                j['email'] as String? ?? '',
        avatarUrl:            j['avatar_url'] as String?,
        emoji:                j['emoji'] as String? ?? '😊',
        role:                 j['role']  as String? ?? 'member',
        notificationsEnabled: j['notifications_enabled'] as bool? ?? true,
        currency:             j['currency'] as String? ?? 'BRL',
        locale:               j['locale']   as String? ?? 'pt_BR',
        createdAt:            DateTime.parse(
            j['created_at'] as String? ?? DateTime.now().toIso8601String()),
        lastSeenAt: j['last_seen_at'] != null
            ? DateTime.parse(j['last_seen_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'name':                   name,
    'avatar_url':             avatarUrl,
    'emoji':                  emoji,
    'notifications_enabled':  notificationsEnabled,
  };
}