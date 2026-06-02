abstract class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => "$runtimeType($code): $message";
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.msg = 'Sem conexao com a internet.'])
      : super(code: 'NETWORK');
}

class AuthFailure extends Failure {
  const AuthFailure([super.msg = 'Erro de autenticacao.'])
      : super(code: 'AUTH');
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.msg = 'Erro no banco de dados.'])
      : super(code: 'DATABASE');
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.msg = 'Dados invalidos.'])
      : super(code: 'VALIDATION');
}

class CacheFailure extends Failure {
  const CacheFailure([super.msg = 'Erro de cache.'])
      : super(code: 'CACHE');
}

class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure([super.msg = 'Regra de negocio violada.'])
      : super(code: 'BUSINESS_RULE');
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.msg = 'Erro desconhecido.'])
      : super(code: 'UNKNOWN');
}
