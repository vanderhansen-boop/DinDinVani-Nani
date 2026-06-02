import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String familyId;
  final String email;
  final String name;
  final String role;
  final String? avatarUrl;
  final String emoji;
  final bool notificationsEnabled;
  final String currency;
  final String locale;
  final DateTime createdAt;
  final DateTime? lastSeenAt;

  const UserModel({
    required this.id,
    required this.familyId,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.emoji = '😊',
    this.notificationsEnabled = true,
    this.currency = 'BRL',
    this.locale = 'pt_BR',
    required this.createdAt,
    this.lastSeenAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    debugPrint('[UserModel.fromJson] raw=$j');

    // Suporte a colunas em PT e EN
    final id       = j['id']                          as String?;
    final familyId = j['family_id']                   as String?;
    final email    = j['email']                       as String?;
    final name     = (j['nome']  ?? j['name'])        as String?;
    final role     = (j['papel'] ?? j['role'])        as String?;

    if (id == null || familyId == null || email == null ||
        name == null || role == null) {
      debugPrint('[UserModel] CAMPOS NULOS: id=$id familyId=$familyId '
          'email=$email name=$name role=$role');
      throw StateError(
        'UserModel.fromJson: campo obrigatorio nulo. '
        'Dados recebidos: $j',
      );
    }

    return UserModel(
      id:                   id,
      familyId:             familyId,
      email:                email,
      name:                 name,
      role:                 role,
      avatarUrl:            j['avatar_url']             as String?,
      emoji:               (j['emoji']                  as String?) ?? '😊',
      notificationsEnabled:(j['notifications_enabled']  as bool?)   ?? true,
      currency:            (j['currency']               as String?) ?? 'BRL',
      locale:              (j['locale']                 as String?) ?? 'pt_BR',
      createdAt:            DateTime.parse(
                              (j['created_at'] as String?) ??
                              DateTime.now().toIso8601String()),
      lastSeenAt:           j['last_seen_at'] != null
                              ? DateTime.parse(j['last_seen_at'] as String)
                              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                    id,
    'family_id':             familyId,
    'email':                 email,
    'nome':                  name,
    'papel':                 role,
    'avatar_url':            avatarUrl,
    'emoji':                 emoji,
    'notifications_enabled': notificationsEnabled,
    'currency':              currency,
    'locale':                locale,
    'created_at':            createdAt.toIso8601String(),
    'last_seen_at':          lastSeenAt?.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? familyId,
    String? email,
    String? name,
    String? role,
    String? avatarUrl,
    String? emoji,
    bool? notificationsEnabled,
    String? currency,
    String? locale,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) => UserModel(
    id:                   id                   ?? this.id,
    familyId:             familyId             ?? this.familyId,
    email:                email                ?? this.email,
    name:                 name                 ?? this.name,
    role:                 role                 ?? this.role,
    avatarUrl:            avatarUrl            ?? this.avatarUrl,
    emoji:                emoji                ?? this.emoji,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    currency:             currency             ?? this.currency,
    locale:               locale               ?? this.locale,
    createdAt:            createdAt            ?? this.createdAt,
    lastSeenAt:           lastSeenAt           ?? this.lastSeenAt,
  );
}
