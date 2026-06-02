class CashflowProjection {
  final int    month;
  final int    year;
  final double projectedIncome;
  final double projectedExpense;
  final bool   isProjection;

  const CashflowProjection({
    required this.month,
    required this.year,
    required this.projectedIncome,
    required this.projectedExpense,
    this.isProjection = true,
  });

  /// alias plural usado nos widgets
  double get projectedExpenses => projectedExpense;

  double get projectedBalance => projectedIncome - projectedExpense;

  /// "Jan/2025"
  String get label {
    const meses = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${meses[month]}/$year';
  }

  /// alias de label
  String get monthLabel => label;

  /// "Janeiro/2025"
  String get monthFull {
    const meses = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${meses[month]}/$year';
  }
}