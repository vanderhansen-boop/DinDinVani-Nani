import '../entities/user_profile.dart';

abstract class IAuthRepository {
  Future<UserProfile?> signIn(String email, String password);
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<void> signOut();
  Future<UserProfile?> getCurrentUserProfile();
  Stream<UserProfile?> get userChanges;
}
