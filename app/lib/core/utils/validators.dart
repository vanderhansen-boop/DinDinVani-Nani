class Validators {
  Validators._();

  static String? required(String? v, {String campo = 'Campo'}) {
    if (v == null || v.trim().isEmpty) return "$campo obrigatorio";
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'E-mail obrigatorio';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\$');
    if (!regex.hasMatch(v)) return 'E-mail invalido';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.length < 6) return 'Minimo 6 caracteres';
    return null;
  }

  static String? amount(String? v) {
    if (v == null || v.isEmpty) return 'Informe um valor';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null || n <= 0) return 'Valor invalido';
    return null;
  }
}
