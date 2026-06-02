import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/allocation_rule.dart';
import '../../../../domain/usecases/get_current_budget.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';
import '../providers/planning_providers.dart';
import '../../../../data/models/budget_model.dart';

class NewBudgetSheet extends ConsumerStatefulWidget {
  final AllocationRule rule;
  const NewBudgetSheet({super.key, required this.rule});

  @override
  ConsumerState<NewBudgetSheet> createState() => _NewBudgetSheetState();
}

class _NewBudgetSheetState extends ConsumerState<NewBudgetSheet> {
  final _incomeCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _incomeCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final income = double.tryParse(_incomeCtrl.text.replaceAll(',', '.'));
    if (income == null || income <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Informe a renda')));
      return;
    }
    setState(() => _saving = true);
    try {
      final familyId = ref.read(currentFamilyIdProvider);
      final useCase  = ref.read(getCurrentBudgetProvider);
      final budget   = useCase.buildFromIncome(
        familyId:    familyId,
        totalIncome: income,
        rule:        widget.rule,
      );
      await ref.read(budgetRepositoryProvider)
          .createOrUpdateBudget(BudgetModel(
            id:               budget.id,
            familyId:         budget.familyId,
            referenceYear:    budget.referenceYear,
            referenceMonth:   budget.referenceMonth,
            budgetYear:       budget.budgetYear,
            budgetMonth:      budget.budgetMonth,
            totalIncome:      budget.totalIncome,
            essentialsLimit:  budget.essentialsLimit,
            wantsLimit:       budget.wantsLimit,
            savingsLimit:     budget.savingsLimit,
            essentialsSpent:  0,
            wantsSpent:       0,
            savingsSpent:     0,
            isLocked:         false,
          ));
      ref.invalidate(currentBudgetProvider);
      ref.invalidate(budgetHistoryProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now        = DateTime.now();
    final budgetDate = DateTime(now.year, now.month + 2, 1);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            const Text('Registrar Renda do Mês',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              'Renda de ${now.month.toString().padLeft(2,"0")}/${now.year} → '
              'Orçamento de ${budgetDate.month.toString().padLeft(2,"0")}/${budgetDate.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _incomeCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0,00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            // Preview alocacao
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PreviewItem('🏠', '${widget.rule.essentialsPercent.toStringAsFixed(0)}%', 'Necessidades'),
                  _PreviewItem('🎉', '${widget.rule.wantsPercent.toStringAsFixed(0)}%',      'Desejos'),
                  _PreviewItem('💰', '${widget.rule.savingsPercent.toStringAsFixed(0)}%',    'Poupança'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_saving ? 'Salvando...' : 'Gerar Orçamento M+2'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String emoji;
  final String percent;
  final String label;
  const _PreviewItem(this.emoji, this.percent, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label,   style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    ],
  );
}