import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/piggy_bank.dart';
import '../providers/piggy_bank_providers.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

class PiggyBankForm extends ConsumerStatefulWidget {
  final PiggyBank? existing;
  const PiggyBankForm({super.key, this.existing});
  @override
  ConsumerState<PiggyBankForm> createState() => _PiggyBankFormState();
}

class _PiggyBankFormState extends ConsumerState<PiggyBankForm> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _targetCtrl = TextEditingController();

  PiggyBankType _type  = PiggyBankType.purpose;
  String        _emoji = '🎯';
  String        _color = '#E65100';
  DateTime?     _targetDate;
  bool          _saving = false;

  static const _emojis = ['🎯','🐷','💳','📦','🛡️','📅','✈️','🏠','🚗','💊','🎓','💍','🎮','📱','💻'];
  static const _colors = ['#E65100','#1565C0','#6A1B9A','#1B5E20','#B71C1C','#37474F','#F57F17','#00695C'];

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _nameCtrl.text   = p.name;
      _targetCtrl.text = p.targetAmount > 0 ? p.targetAmount.toStringAsFixed(2) : '';
      _type            = p.type;
      _emoji           = p.emoji;
      _color           = p.color ?? '#E65100';
      _targetDate      = p.targetDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final familyId = ref.read(currentFamilyIdProvider);
      final target   = double.tryParse(_targetCtrl.text.replaceAll(',', '.')) ?? 0.0;

      final p = PiggyBank(
        id:             widget.existing?.id ?? '',
        familyId:       familyId,
        name:           _nameCtrl.text.trim(),
        emoji:          _emoji,
        type:           _type,
        currentBalance: widget.existing?.currentBalance ?? 0.0,
        targetAmount:   target,
        targetDate:     _targetDate,
        isActive:       true,
        color:          _color,
      );

      final save = ref.read(savePiggyBankProvider);
      if (widget.existing == null) {
        await save.create(p);
      } else {
        await save.update(p);
      }
      ref.invalidate(piggyBankListProvider);
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
        title: Text(widget.existing == null ? 'Nova Caixinha' : 'Editar Caixinha'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo
            DropdownButtonFormField<PiggyBankType>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Tipo de caixinha',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.category_rounded),
              ),
              items: const [
                DropdownMenuItem(value: PiggyBankType.invoice,     child: Text('💳  CF — Caixinha de Fatura')),
                DropdownMenuItem(value: PiggyBankType.installment, child: Text('📦  CPI — Parcela Integral')),
                DropdownMenuItem(value: PiggyBankType.purpose,     child: Text('🎯  CP — Propósito / Meta')),
                DropdownMenuItem(value: PiggyBankType.emergency,   child: Text('🛡️  CE — Emergência')),
                DropdownMenuItem(value: PiggyBankType.monthly,     child: Text('📅  CM — Caixinha do Mês')),
                DropdownMenuItem(value: PiggyBankType.custom,      child: Text('⭐  Personalizada')),
              ],
              onChanged: (v) => setState(() => _type = v ?? PiggyBankType.custom),
            ),
            const SizedBox(height: 12),

            // Nome
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nome da caixinha *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.label_rounded),
              ),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),

            // Emoji picker
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Ícone',
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

            // Color picker
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Cor',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Wrap(
                spacing: 8,
                children: _colors.map((c) {
                  final color = Color(int.tryParse(c.replaceFirst('#', '0xFF')) ?? 0xFF607D8B);
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _color == c
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: _color == c
                            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Meta valor
            TextFormField(
              controller: _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              decoration: InputDecoration(
                labelText: 'Valor da meta (opcional)',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.flag_rounded),
              ),
            ),
            const SizedBox(height: 12),

            // Data da meta
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300)),
              leading: const Icon(Icons.event_rounded),
              title: Text(_targetDate == null
                  ? 'Data da meta (opcional)'
                  : 'Meta: ${_targetDate!.day.toString().padLeft(2,"0")}/${_targetDate!.month.toString().padLeft(2,"0")}/${_targetDate!.year}'),
              trailing: _targetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _targetDate = null))
                  : const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2040),
                  locale: const Locale('pt', 'BR'),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
            ),
            const SizedBox(height: 24),

            // Botao
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Salvando...' : 'Salvar Caixinha'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
