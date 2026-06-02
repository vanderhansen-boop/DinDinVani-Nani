/// Ponto de dados mensais para graficos
class MonthlyData {
  final String month;   // Ex: 'Jan', 'Fev', etc.
  final double income;
  final double expense;

  const MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get balance => income - expense;
  bool   get isPositive => balance >= 0;
}
