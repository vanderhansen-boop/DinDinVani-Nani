import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formata input como R\$ enquanto o usuario digita.
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _f = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    if (newV.text.isEmpty) return newV.copyWith(text: '');
    final digits = newV.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final value = double.parse(digits) / 100;
    final formatted = _f.format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
