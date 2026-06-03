import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/features/auth/providers/auth_notifier.dart';
import '../../presentation/features/auth/providers/auth_state.dart';

/// Provê o cliente Supabase global
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provê o ID da família do usuário logado.
///
/// CORRIGIDO: lê o family_id do UserProfile carregado da tabela
/// public.users (via AuthAuthenticated), e NÃO dos userMetadata
/// do auth.users (que vinham vazios e causavam o erro
/// "invalid input syntax for type uuid: \"\"").
final currentFamilyIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthAuthenticated) {
    return authState.user.familyId;
  }
  return '';
});

/// Provê o ID do usuário logado.
final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthAuthenticated) {
    return authState.user.id;
  }
  return Supabase.instance.client.auth.currentUser?.id ?? '';
});
