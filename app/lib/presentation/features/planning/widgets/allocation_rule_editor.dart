import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/allocation_rule.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';
import '../providers/planning_providers.dart';

class AllocationRuleEditor extends ConsumerStatefulWidget {
  final AllocationRule current;
  const AllocationRuleEditor({super.key, required this.current});

  @override
  ConsumerState<AllocationRuleEditor> createState() => _AllocationRuleEditorState();
}

class _AllocationRuleEditorState extends ConsumerState<AllocationRuleEditor> {
  late double _essentials;
  late double _wants;
  late double _savings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _essentials = widget.current.essentialsPercent;
    _wants      = widget.current.wantsPercent;
    _savings    = widget.current.savingsPercent;
  }

  double get _total => _essentials + _wants + _savings;
  bool  get _valid  => _total == 100;

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      final familyId = ref.read(currentFamilyIdProvider);
      final rule = AllocationRule(
        essentialsPercent: _essentials,
        wantsPercent:      _wants,
        savingsPercent:    _savings,
      );
      await ref.read(manageAllocationRuleProvider).save(familyId, rule);
      ref.invalidate(allocationRuleProvider);
      ref.invalidate(currentBudgetProvider);
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
            const Text('Regra de Alocação',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4),
            Text('A soma deve ser 100%  (atual: ${_total.toStringAsFixed(0)}%)',
                style: TextStyle(
                    fontSize: 12,
                    color: _valid ? Colors.grey : Colors.red)),
            const SizedBox(height: 20),

            _SliderRow(emoji: '🏠', label: 'Necessidades', color: const Color(0xFF1565C0),
                value: _essentials,
                onChanged: (v) => setState(() => _essentials = v)),
            const SizedBox(height: 12),
            _SliderRow(emoji: '🎉', label: 'Desejos', color: const Color(0xFFE65100),
                value: _wants,
                onChanged: (v) => setState(() => _wants = v)),
            const SizedBox(height: 12),
            _SliderRow(emoji: '💰', label: 'Poupança', color: const Color(0xFF1B5E20),
                value: _savings,
                onChanged: (v) => setState(() => _savings = v)),
            const SizedBox(height: 20),

            // Preview mini
            Row(
              children: [
                _Chip('🏠 ${_essentials.toStringAsFixed(0)}%', const Color(0xFF1565C0)),
                const SizedBox(width: 6),
                _Chip('🎉 ${_wants.toStringAsFixed(0)}%', const Color(0xFFE65100)),
                const SizedBox(width: 6),
                _Chip('💰 ${_savings.toStringAsFixed(0)}%', const Color(0xFF1B5E20)),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_valid && !_saving) ? _save : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_saving ? 'Salvando...' : 'Salvar Regra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String   emoji;
  final String   label;
  final Color    color;
  final double   value;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.emoji,
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 120,
        child: Text('$emoji $label', style: const TextStyle(fontSize: 13)),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor:       color,
            overlayColor:     color.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ),
      SizedBox(
        width: 40,
        child: Text('${value.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color  color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
  );
}