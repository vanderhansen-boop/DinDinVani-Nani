class Goal {
  final String id;
  final String familyId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? piggyBankId;
  final String status;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.familyId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    required this.createdAt,
    this.description,
    this.targetDate,
    this.piggyBankId,
  });

  double get progress {
    if (targetAmount == 0) return 0;
    final p = currentAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  bool get isCompleted => currentAmount >= targetAmount;
}
