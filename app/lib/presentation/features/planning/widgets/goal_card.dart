import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/family_goal.dart';

class GoalCard extends StatelessWidget {
  final FamilyGoal   goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color get _priorityColor {
    switch (goal.priority) {
      case GoalPriority.high:   return Colors.red;
      case GoalPriority.medium: return Colors.orange;
      case GoalPriority.low:    return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent;
    final monthly  = goal.monthlyRequired;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _priorityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(goal.priorityLabel,
                                  style: TextStyle(
                                      fontSize: 10, color: _priorityColor,
                                      fontWeight: FontWeight.w600)),
                            ),
                            if (goal.targetDate != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '📅 ${goal.targetDate!.month.toString().padLeft(2,"0")}/${goal.targetDate!.year}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit')   onEdit?.call();
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit',   child: Text('✏️  Editar')),
                      PopupMenuItem(value: 'delete', child: Text('🗑️  Remover')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progresso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(goal.currentAmount.toBRL,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18,
                          color: Color(0xFF1B5E20))),
                  Text('de ${goal.targetAmount.toBRL}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted ? Colors.green : const Color(0xFF1565C0)),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goal.isCompleted
                        ? '✅ Meta atingida!'
                        : '${(progress * 100).toStringAsFixed(1)}% concluído',
                    style: TextStyle(
                      fontSize: 11,
                      color: goal.isCompleted ? Colors.green : Colors.grey[600],
                      fontWeight: goal.isCompleted
                          ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (monthly != null && !goal.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${monthly.toBRL}/mês',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),

              // Descricao
              if (goal.description != null &&
                  goal.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(goal.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
