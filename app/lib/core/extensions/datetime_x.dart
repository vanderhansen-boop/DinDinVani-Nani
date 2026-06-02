import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toBR() => DateFormat('dd/MM/yyyy', 'pt_BR').format(this);

  String toBRTime() => DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(this);

  String toBRFull() => DateFormat("dd 'de' MMMM 'de' yyyy", "pt_BR").format(this);

  String toMonthYear() => DateFormat('MMMM/yyyy', 'pt_BR').format(this);

  String toShortMonth() => DateFormat('MMM/yy', 'pt_BR').format(this);

  bool get isToday {
    final n = DateTime.now();
    return year == n.year && month == n.month && day == n.day;
  }

  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  DateTime get lastDayOfMonth  => DateTime(year, month + 1, 0);

  DateTime addMonths(int n) => DateTime(year, month + n, day);
}
