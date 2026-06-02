import 'package:intl/intl.dart';

extension DoubleX on double {
  String toBRL({bool showSymbol = true}) {
    final f = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: showSymbol ? 'R\$' : '',
      decimalDigits: 2,
    );
    return f.format(this).trim();
  }

  String toBRNumber({int decimals = 2}) {
    final f = NumberFormat.decimalPattern('pt_BR');
    f.minimumFractionDigits = decimals;
    f.maximumFractionDigits = decimals;
    return f.format(this);
  }

  String toPercent({int decimals = 0}) {
    final f = NumberFormat.percentPattern('pt_BR');
    f.minimumFractionDigits = decimals;
    f.maximumFractionDigits = decimals;
    return f.format(this);
  }
}
