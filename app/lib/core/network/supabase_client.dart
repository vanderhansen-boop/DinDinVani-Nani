import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper do cliente Supabase.
/// As chaves vem do .env carregado em main.dart via flutter_dotenv.
class SupabaseService {
  SupabaseService._();

  static String get url =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Inicializa o Supabase. Deve ser chamado em main() apos dotenv.load().
  /// IMPORTANTE: main.dart ja chama Supabase.initialize diretamente,
  /// entao esse metodo serve como utilitario alternativo.
  static Future<void> init() async {
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL ou SUPABASE_ANON_KEY nao encontrados no .env. '
        'Verifique se o arquivo .env existe em app/ e esta listado em '
        'pubspec.yaml -> flutter -> assets.',
      );
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
}
