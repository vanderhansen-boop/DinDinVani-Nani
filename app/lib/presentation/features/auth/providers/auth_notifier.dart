import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/failure.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthInitial()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUserProfile();
      state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      final useCase = ref.read(signInUseCaseProvider);
      final user = await useCase(email, password);
      state = user != null ? AuthAuthenticated(user) : const AuthError('Credenciais invalidas');
    } on Failure catch (f) {
      state = AuthError(f.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthLoading();
    try {
      final useCase = ref.read(signUpUseCaseProvider);
      final user = await useCase(email: email, password: password, name: name);
      state = user != null ? AuthAuthenticated(user) : const AuthError('Falha ao cadastrar');
    } on Failure catch (f) {
      state = AuthError(f.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await ref.read(signOutUseCaseProvider).call();
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

