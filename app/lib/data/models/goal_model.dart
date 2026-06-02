class GoalModel {
  final String id;
  final String familyId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? icon;
  final String status; // active, completed, paused
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    this.icon,
    required this.status,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  factory GoalModel.fromJson(Map<String, dynamic> j) => GoalModel(
        id: j['id'] as String,
        familyId: j['family_id'] as String,
        name: j['name'] as String,
        targetAmount: (j['target_amount'] as num).toDouble(),
        currentAmount: (j['current_amount'] as num).toDouble(),
        targetDate: j['target_date'] != null ? DateTime.parse(j['target_date'] as String) : null,
        icon: j['icon'] as String?,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
