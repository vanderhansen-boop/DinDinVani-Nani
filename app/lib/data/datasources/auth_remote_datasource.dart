import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/errors/exceptions.dart' as app_ex;
import '../models/user_model.dart';

class AuthRemoteDataSource {
  SupabaseClient get _client => SupabaseService.client;

  Future<AuthResponse> signIn(String email, String password) async {
    debugPrint('[AUTH] signIn iniciado: $email');
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('[AUTH] signIn OK: userId=${res.user?.id}');
      return res;
    } on AuthException catch (e) {
      debugPrint('[AUTH] signIn ERRO AuthException: ${e.message}');
      throw app_ex.AuthException(e.message);
    } catch (e, st) {
      debugPrint('[AUTH] signIn ERRO inesperado: $e');
      debugPrint('$st');
      throw app_ex.ServerException(e.toString());
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    debugPrint('[AUTH] signUp iniciado: email=$email name=$name');
    debugPrint('[AUTH] Supabase URL=${SupabaseService.url}');
    debugPrint('[AUTH] anonKey len=${SupabaseService.anonKey.length}');

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      debugPrint('[AUTH] signUp resposta:');
      debugPrint('  user=${res.user?.id}');
      debugPrint('  email=${res.user?.email}');
      debugPrint('  emailConfirmedAt=${res.user?.emailConfirmedAt}');
      debugPrint('  session=${res.session != null ? "OK" : "null"}');

      if (res.user == null) {
        throw app_ex.AuthException(
          'signUp retornou usuario nulo. Verifique configuracoes do Supabase.',
        );
      }

      return res;
    } on AuthException catch (e) {
      debugPrint('[AUTH] signUp ERRO AuthException: ${e.message}');
      debugPrint('  statusCode=${e.statusCode}');
      throw app_ex.AuthException(e.message);
    } catch (e, st) {
      debugPrint('[AUTH] signUp ERRO inesperado: $e');
      debugPrint('$st');
      throw app_ex.ServerException(e.toString());
    }
  }

  Future<void> signOut() async {
    debugPrint('[AUTH] signOut');
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('[AUTH] getCurrentUserProfile: sem usuario logado');
      return null;
    }
    debugPrint('[AUTH] getCurrentUserProfile: id=${user.id}');
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (data == null) {
        debugPrint('[AUTH] perfil nao encontrado na tabela users');
        return null;
      }
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      debugPrint('[AUTH] erro ao buscar perfil: $e');
      rethrow;
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
