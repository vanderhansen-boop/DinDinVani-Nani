import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/credit_card.dart';
import '../providers/credit_card_providers.dart';

class CreditCardForm extends ConsumerStatefulWidget {
  final CreditCard? existing;
  const CreditCardForm({super.key, this.existing});

  @override
  ConsumerState<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends ConsumerState<CreditCardForm> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _limitCtrl  = TextEditingController();
  final _last4Ctrl  = TextEditingController();

  int     _closingDay = 1;
  int     _dueDay     = 5;
  String  _brand      = 'Visa';
  String  _emoji      = '💳';
  String  _color      = '#1976D2';

  static const _brands = ['Visa', 'Mastercard', 'Elo', 'Amex', 'Hipercard', 'Outro'];
  static const _emojis = ['💳', '💜', '🖤', '💙', '🩵', '🟡'];
  static const _colors = ['#1976D2', '#7B1FA2', '#212121', '#00897B', '#F57C00', '#C62828'];

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    if (c != null) {
      _nameCtrl.text  = c.name;
      _limitCtrl.text = c.creditLimit.toStringAsFixed(2);
      _last4Ctrl.text = c.lastFourDigits ?? '';
      _brand          = c.brand          ?? 'Visa';
      _emoji          = c.emoji          ?? '💳';
      _color          = c.color          ?? '#1976D2';
      _closingDay     = c.closingDay;
      _dueDay         = c.dueDay;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _limitCtrl.dispose();
    _last4Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(creditCardRepositoryProvider);
    final card = CreditCard(
      id:             widget.existing?.id ?? '',
      familyId:       widget.existing?.familyId ?? '',
      name:           _nameCtrl.text.trim(),
      creditLimit:    double.tryParse(_limitCtrl.text.replaceAll(',', '.')) ?? 0,
      closingDay:     _closingDay,
      dueDay:         _dueDay,
      lastFourDigits: _last4Ctrl.text.trim().isEmpty ? null : _last4Ctrl.text.trim(),
      brand:          _brand,
      emoji:          _emoji,
      color:          _color,
    );
    try {
      if (widget.existing == null) {
        await repo.createCard(card);
      } else {
        await repo.updateCard(card);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Cartão' : 'Novo Cartão'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Emoji picker
            Center(
              child: Wrap(
                spacing: 8,
                children: _emojis.map((e) => GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _emoji == e ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 28)),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Nome
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do cartão *', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            // Limite
            TextFormField(
              controller: _limitCtrl,
              decoration: const InputDecoration(labelText: 'Limite (R\$) *', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                return (n == null || n <= 0) ? 'Informe um valor válido' : null;
              },
            ),
            const SizedBox(height: 12),
            // Últimos 4 dígitos
            TextFormField(
              controller: _last4Ctrl,
              decoration: const InputDecoration(labelText: 'Últimos 4 dígitos', border: OutlineInputBorder()),
              maxLength: 4,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            // Bandeira
            DropdownButtonFormField<String>(
              value: _brand,
              decoration: const InputDecoration(labelText: 'Bandeira', border: OutlineInputBorder()),
              items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() => _brand = v ?? _brand),
            ),
            const SizedBox(height: 12),
            // Fechamento e vencimento
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _closingDay,
                    decoration: const InputDecoration(labelText: 'Dia fechamento', border: OutlineInputBorder()),
                    items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) => setState(() => _closingDay = v ?? _closingDay),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _dueDay,
                    decoration: const InputDecoration(labelText: 'Dia vencimento', border: OutlineInputBorder()),
                    items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) => setState(() => _dueDay = v ?? _dueDay),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Cor
            const Text('Cor do cartão:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color == c ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}