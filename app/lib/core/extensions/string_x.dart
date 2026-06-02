extension StringX on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : w.capitalize)
      .join(' ');

  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+\$').hasMatch(this);

  String get onlyDigits => replaceAll(RegExp(r'[^0-9]'), '');

  double toBRDouble() {
    final clean = replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }
}
