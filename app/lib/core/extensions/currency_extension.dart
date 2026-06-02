// lib/core/extensions/currency_extension.dart
extension CurrencyExtension on double {
  String get toBRL {
    final abs = this.abs();
    final formatted = abs.toStringAsFixed(2).replaceAll('.', ',');
    final parts = formatted.split(',');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
      count++;
    }
    final intFormatted = buffer.toString().split('').reversed.join();
    final signal = this < 0 ? '-' : '';
    return '${signal}R\$ $intFormatted,$decPart';
  }

  String get toPercent => '${toStringAsFixed(1)}%';
}