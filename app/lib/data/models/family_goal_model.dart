import '../../domain/entities/family_goal.dart';

class FamilyGoalModel extends FamilyGoal {
  const FamilyGoalModel({
    required super.id,
    required super.familyId,
    required super.name,
    required super.emoji,
    super.description,
    required super.targetAmount,
    required super.currentAmount,
    super.targetDate,
    required super.status,
    required super.priority,
    super.piggyBankId,
    required super.createdAt,
  });

  factory FamilyGoalModel.fromJson(Map<String, dynamic> j) => FamilyGoalModel(
    id:            j['id']             as String,
    familyId:      j['family_id']      as String,
    name:          j['name']           as String,
    emoji:         j['emoji']          as String? ?? '🎯',
    description:   j['description']    as String?,
    targetAmount:  (j['target_amount'] as num).toDouble(),
    currentAmount: (j['current_amount'] as num? ?? 0).toDouble(),
    targetDate:    j['target_date'] != null
        ? DateTime.parse(j['target_date'] as String) : null,
    status:    _statusFrom(j['status']     as String? ?? 'active'),
    priority:  _priorityFrom(j['priority'] as String? ?? 'medium'),
    piggyBankId: j['piggy_bank_id']   as String?,
    createdAt:   DateTime.parse(j['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'family_id':     familyId,
    'name':          name,
    'emoji':         emoji,
    'description':   description,
    'target_amount': targetAmount,
    'target_date':   targetDate?.toIso8601String(),
    'status':        status.name,
    'priority':      priority.name,
    'piggy_bank_id': piggyBankId,
  };

  static GoalStatus _statusFrom(String s) {
    switch (s) {
      case 'completed': return GoalStatus.completed;
      case 'paused':    return GoalStatus.paused;
      case 'cancelled': return GoalStatus.cancelled;
      default:          return GoalStatus.active;
    }
  }

  static GoalPriority _priorityFrom(String s) {
    switch (s) {
      case 'high': return GoalPriority.high;
      case 'low':  return GoalPriority.low;
      default:     return GoalPriority.medium;
    }
  }
}