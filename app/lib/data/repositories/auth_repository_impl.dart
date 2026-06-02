import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  UserProfile? _toEntity(UserModel? m) {
    if (m == null) return null;
    return UserProfile(
      id:                   m.id,
      familyId:             m.familyId,
      email:                m.email,
      name:                 m.name,
      role:                 m.role,
      avatarUrl:            m.avatarUrl,
      emoji:                m.emoji,
      notificationsEnabled: m.notificationsEnabled,
      currency:             m.currency,
      locale:               m.locale,
      createdAt:            m.createdAt,
      lastSeenAt:           m.lastSeenAt,
    );
  }

  @override
  Future<UserProfile?> signIn(String email, String password) async {
    try {
      await remote.signIn(email, password);
      final user = await remote.getCurrentUserProfile();
      return _toEntity(user);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await remote.signUp(email: email, password: password, name: name);
      final user = await remote.getCurrentUserProfile();
      return _toEntity(user);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signOut() => remote.signOut();

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = await remote.getCurrentUserProfile();
    return _toEntity(user);
  }

  @override
  Stream<UserProfile?> get userChanges async* {
    final client = sb.Supabase.instance.client;
    yield await getCurrentUserProfile();
    await for (final _ in client.auth.onAuthStateChange) {
      yield await getCurrentUserProfile();
    }
  }
}
