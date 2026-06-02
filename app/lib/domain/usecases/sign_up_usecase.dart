import '../entities/user_profile.dart';
import '../repositories/i_auth_repository.dart';
import '../../core/errors/failure.dart';

class SignUpUseCase {
  final IAuthRepository repo;
  SignUpUseCase(this.repo);

  Future<UserProfile?> call({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!email.contains('@')) {
      throw const ValidationFailure('Email invalido');
    }
    if (password.length < 6) {
      throw const ValidationFailure('Senha precisa ter ao menos 6 caracteres');
    }
    if (name.trim().isEmpty) {
      throw const ValidationFailure('Nome obrigatorio');
    }
    return repo.signUp(email: email, password: password, name: name);
  }
}
