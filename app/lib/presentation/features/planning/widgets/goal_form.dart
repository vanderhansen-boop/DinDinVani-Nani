import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/family_goal.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';
import '../providers/planning_providers.dart';
import '../../../../data/models/family_goal_model.dart';

class GoalForm extends ConsumerStatefulWidget {
  final FamilyGoal? existing;
  const GoalForm({super.key, this.existing});

  @override
  ConsumerState<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<GoalForm> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _targetCtrl= TextEditingController();
  final _descCtrl  = TextEditingController();

  String        _emoji    = '🎯';
  GoalPriority  _priority = GoalPriority.medium;
  DateTime?     _targetDate;
  bool          _saving   = false;

  static const _emojis = [
    '🎯','✈️','🏠','🚗','💊','🎓','💍','🎮','📱','💻',
    '🏖️','🐶','📚','🍕','🏋️','🎸','🎨','⛵','🏕️','💎',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    if (g != null) {
      _nameCtrl.text   = g.name;
      _targetCtrl.text = g.targetAmount.toStringAsFixed(2);
      _descCtrl.text   = g.description ?? '';
      _emoji           = g.emoji;
      _priority        = g.priority;
      _targetDate      = g.targetDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final familyId = ref.read(currentFamilyIdProvider);
      final target   = double.tryParse(_targetCtrl.text.replaceAll(',', '.')) ?? 0.0;

      final goal = FamilyGoalModel(
        id:            widget.existing?.id ?? '',
        familyId:      familyId,
        name:          _nameCtrl.text.trim(),
        emoji:         _emoji,
        description:   _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        targetAmount:  target,
        currentAmount: widget.existing?.currentAmount ?? 0.0,
        targetDate:    _targetDate,
        status:        widget.existing?.status ?? GoalStatus.active,
        priority:      _priority,
        createdAt:     widget.existing?.createdAt ?? DateTime.now(),
      );

      final manage = ref.read(manageGoalsProvider);
      if (widget.existing == null) {
        await manage.create(goal);
      } else {
        await manage.update(goal);
      }
      ref.invalidate(goalsProvider);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Nova Meta' : 'Editar Meta'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Emoji
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Ícone da meta',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Wrap(
                spacing: 8,
                children: _emojis.map((e) => GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _emoji == e
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Nome
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nome da meta *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.flag_rounded),
              ),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),

            // Valor alvo
            TextFormField(
              controller: _targetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
              ],
              decoration: InputDecoration(
                labelText: 'Valor da meta *',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              validator: (v) {
                final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                return (n == null || n <= 0) ? 'Valor inválido' : null;
              },
            ),
            const SizedBox(height: 12),

            // Descricao
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 12),

            // Prioridade
            DropdownButtonFormField<GoalPriority>(
              value: _priority,
              decoration: InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.priority_high_rounded),
              ),
              items: const [
                DropdownMenuItem(value: GoalPriority.high,   child: Text('🔴  Alta')),
                DropdownMenuItem(value: GoalPriority.medium, child: Text('🟡  Média')),
                DropdownMenuItem(value: GoalPriority.low,    child: Text('🟢  Baixa')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? GoalPriority.medium),
            ),
            const SizedBox(height: 12),

            // Data alvo
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300)),
              leading: const Icon(Icons.event_rounded),
              title: Text(_targetDate == null
                  ? 'Data alvo (opcional)'
                  : 'Até: ${_targetDate!.day.toString().padLeft(2,"0")}/${_targetDate!.month.toString().padLeft(2,"0")}/${_targetDate!.year}'),
              trailing: _targetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _targetDate = null))
                  : const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2040),
                  locale: const Locale('pt', 'BR'),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Salvando...' : 'Salvar Meta'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}