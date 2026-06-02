enum GoalStatus { active, completed, paused, cancelled }
enum GoalPriority { high, medium, low }

class FamilyGoal {
  final String       id;
  final String       familyId;
  final String       name;
  final String       emoji;
  final String?      description;
  final double       targetAmount;
  final double       currentAmount;
  final DateTime?    targetDate;
  final GoalStatus   status;
  final GoalPriority priority;
  final String?      piggyBankId; // caixinha associada
  final DateTime     createdAt;

  const FamilyGoal({
    required this.id,
    required this.familyId,
    required this.name,
    required this.emoji,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.status,
    required this.priority,
    this.piggyBankId,
    required this.createdAt,
  });

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  /// Meses restantes ate a data alvo
  int? get monthsRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    return ((targetDate!.year - now.year) * 12 +
            (targetDate!.month - now.month))
        .clamp(0, 9999);
  }

  /// Valor mensal necessario para bater a meta
  double? get monthlyRequired {
    final months = monthsRemaining;
    if (months == null || months == 0) return null;
    return remaining / months;
  }

  String get priorityLabel {
    switch (priority) {
      case GoalPriority.high:   return 'Alta';
      case GoalPriority.medium: return 'Media';
      case GoalPriority.low:    return 'Baixa';
    }
  }

  String get statusLabel {
    switch (status) {
      case GoalStatus.active:    return 'Ativa';
      case GoalStatus.completed: return 'Concluida';
      case GoalStatus.paused:    return 'Pausada';
      case GoalStatus.cancelled: return 'Cancelada';
    }
  }
}