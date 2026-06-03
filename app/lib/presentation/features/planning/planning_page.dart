import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/family_goal.dart';
import 'providers/planning_providers.dart';
import 'widgets/budget_503020_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/allocation_rule_editor.dart';
import 'widgets/new_budget_sheet.dart';
import 'widgets/goal_form.dart';
import '../../../../core/extensions/currency_extension.dart';

class PlanningPage extends ConsumerWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(currentBudgetProvider);
    final goalsAsync  = ref.watch(goalsProvider);
    final ruleAsync   = ref.watch(allocationRuleProvider);
    final monthlyNeed = ref.watch(totalMonthlyGoalRequiredProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentBudgetProvider);
            ref.invalidate(goalsProvider);
            ref.invalidate(allocationRuleProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            children: [
              // ─── Secao Orcamento 50/30/20 ───
              _SectionHeader(
                emoji: '📊',
                title: 'Orçamento Defasado (OD)',
                subtitle: 'Renda de M define orçamento de M+2',
                action: TextButton.icon(
                  onPressed: () => ruleAsync.when(
                    data:    (rule) => _openAllocationEditor(context, ref, rule),
                    loading: () {},
                    error:   (_, __) {},
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Regra'),
                ),
              ),
              const SizedBox(height: 8),

              budgetAsync.when(
                loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    )),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (budget) {
                  if (budget == null) {
                    return _EmptyBudgetCard(
                      onTap: () => ruleAsync.when(
                        data:    (rule) => _openNewBudget(context, ref, rule),
                        loading: () {},
                        error:   (_, __) {},
                      ),
                    );
                  }
                  return Budget503020Card(budget: budget);
                },
              ),

              const SizedBox(height: 20),

              // ─── Secao Metas ───
              _SectionHeader(
                emoji: '🎯',
                title: 'Metas do Casal',
                subtitle: monthlyNeed > 0
                    ? 'Total mensal necessário: ${monthlyNeed.toBRL}'
                    : 'Defina metas financeiras juntos',
                action: FilledButton.icon(
                  onPressed: () => _openGoalForm(context, ref),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Nova meta'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              goalsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => Center(child: Text('Erro: $e')),
                data: (goals) {
                  if (goals.isEmpty) {
                    return _EmptyGoalsCard(
                        onTap: () => _openGoalForm(context, ref));
                  }

                  // Ordenar: alta prioridade primeiro, depois % progresso
                  final sorted = [...goals]..sort((a, b) {
                    const p = [GoalPriority.high, GoalPriority.medium, GoalPriority.low];
                    final cmp = p.indexOf(a.priority).compareTo(p.indexOf(b.priority));
                    if (cmp != 0) return cmp;
                    return b.progressPercent.compareTo(a.progressPercent);
                  });

                  return Column(
                    children: sorted.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GoalCard(
                        goal: g,
                        onEdit: () => _openGoalForm(context, ref, existing: g),
                        onDelete: () => _confirmDelete(context, ref, g),
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAllocationEditor(BuildContext context, WidgetRef ref, rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AllocationRuleEditor(current: rule),
    );
  }

  void _openNewBudget(BuildContext context, WidgetRef ref, rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => NewBudgetSheet(rule: rule),
    );
  }

  void _openGoalForm(BuildContext context, WidgetRef ref,
      {FamilyGoal? existing}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GoalForm(existing: existing)),
    ).then((ok) { if (ok == true) ref.invalidate(goalsProvider); });
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FamilyGoal g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remover "${g.name}"?'),
        content: const Text('A meta será cancelada. Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(manageGoalsProvider).delete(g.id);
      ref.invalidate(goalsProvider);
    }
  }
}

// ──────────────────────────────────────────────────────────
// Widgets auxiliares
// ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String   emoji;
  final String   title;
  final String   subtitle;
  final Widget?  action;

  const _SectionHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
      if (action != null) action!,
    ],
  );
}

class _EmptyBudgetCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyBudgetCard({required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('📊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('Sem orçamento este mês',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Registre a renda do mês para gerar o\norçamento defasado (OD) de M+2',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar Renda'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyGoalsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyGoalsCard({required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text('Nenhuma meta ainda',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Defina objetivos financeiros juntos!\nViagem, casa, carro, reserva...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.flag_rounded),
            label: const Text('Criar Primeira Meta'),
          ),
        ],
      ),
    ),
  );
}
