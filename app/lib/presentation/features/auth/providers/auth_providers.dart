import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../domain/usecases/sign_in_usecase.dart';
import '../../../../domain/usecases/sign_up_usecase.dart';
import '../../../../domain/usecases/sign_out_usecase.dart';

/// Cliente Supabase global
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// DataSource
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // ignore: unused_local_variable
  final _ = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSource();
});

/// Repository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

/// Use Cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});
