class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final String categoryEmoji;
  final double amount;
  final double percentage;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.categoryEmoji,
    required this.amount,
    required this.percentage,
  });

  // ── Aliases usados pelo CategoryPieChart (formato MapEntry) ──────────────
  String get key   => categoryName;
  double get value => amount;
}

class MonthlySummary {
  final int    month;
  final int    year;
  final double income;
  final double expense;
  final List<CategoryBreakdown> byCategory;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
    this.byCategory = const [],
  });

  // ── Aliases de valores ──────────────────────────────────────────────────
  double get totalIncome   => income;
  double get totalExpenses => expense;
  double get balance       => income - expense;

  bool   get isPositive    => balance >= 0;

  /// Taxa de poupança em % (saldo / receita)
  double get savingsRate {
    if (income <= 0) return 0;
    return (balance / income) * 100;
  }

  /// Top categorias ordenadas por valor (desc)
  List<CategoryBreakdown> get topCategories {
    final list = [...byCategory]..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  // ── Labels ──────────────────────────────────────────────────────────────
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