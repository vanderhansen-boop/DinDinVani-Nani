import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provê o cliente Supabase global
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provê o ID da família do usuário logado
final currentFamilyIdProvider = Provider<String>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  // O family_id fica nos metadados do usuário
  final meta = user?.userMetadata;
  return (meta?['family_id'] as String?) ?? '';
});

/// Provê o ID do usuário logado
final currentUserIdProvider = Provider<String>((ref) {
  return Supabase.instance.client.auth.currentUser?.id ?? '';
});