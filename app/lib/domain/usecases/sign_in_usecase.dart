import '../entities/user_profile.dart';
import '../repositories/i_auth_repository.dart';
import '../../core/errors/failure.dart';

class SignInUseCase {
  final IAuthRepository repo;
  SignInUseCase(this.repo);

  Future<UserProfile?> call(String email, String password) async {
    if (!email.contains('@')) {
      throw const ValidationFailure('Email invalido');
    }
    if (password.length < 6) {
      throw const ValidationFailure('Senha precisa ter ao menos 6 caracteres');
    }
    return repo.signIn(email, password);
  }
}
