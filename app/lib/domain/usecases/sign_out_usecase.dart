import '../repositories/i_auth_repository.dart';

class SignOutUseCase {
  final IAuthRepository repo;
  SignOutUseCase(this.repo);

  Future<void> call() => repo.signOut();
}
