import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
// lib/presentation/features/transactions/widgets/transaction_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/category.dart';
import '../providers/transaction_providers.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final Transaction? existing;
  const TransactionForm({super.key, this.existing});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey    = GlobalKey<FormState>();
  final _descCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();

  TransactionType _type         = TransactionType.expense;
  RecurrenceType  _recurrence   = RecurrenceType.none;
  DateTime        _date         = DateTime.now();
  String?         _categoryId;
  bool            _isPaid       = true;
  bool            _isCredit     = false;
  int             _installments = 1;
  bool            _saving       = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    if (t != null) {
      _descCtrl.text   = t.description;
      _amountCtrl.text = t.amount.toStringAsFixed(2);
      _notesCtrl.text  = t.notes ?? '';
      _type            = t.type;
      _recurrence      = t.recurrence;
      _date            = t.date;
      _categoryId      = t.categoryId;
      _isPaid          = t.isPaid;
      _isCredit        = t.isCredit;
      _installments    = t.installments ?? 1;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(List<Category> categories) async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecione uma categoria')));
      return;
    }
    setState(() => _saving = true);
    try {
      final familyId = ref.read(currentFamilyIdProvider);
      final userId   = Supabase.instance.client.auth.currentUser!.id;
      final amount   = double.parse(_amountCtrl.text.replaceAll(',', '.'));

      final t = Transaction(
        id:                 widget.existing?.id ?? '',
        familyId:           familyId,
        accountId:          'default',
        categoryId:         _categoryId!,
        description:        _descCtrl.text.trim(),
        amount:             amount,
        type:               _type,
        date:               _date,
        isPaid:             _isPaid,
        recurrence:         _recurrence,
        installments:       _installments > 1 ? _installments : null,
        currentInstallment: _installments > 1 ? 1 : null,
        notes:              _notesCtrl.text.trim().isEmpty
                                ? null : _notesCtrl.text.trim(),
        createdBy:          userId,
      );

      final save = ref.read(saveTransactionProvider);
      if (widget.existing == null) {
        await save.create(t);
      } else {
        await save.update(t);
      }

      ref.invalidate(transactionListProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? 'Novo Lançamento' : 'Editar Lançamento'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Erro: $e')),
        data: (categories) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tipo
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.income,
                      label: Text('Receita'),
                      icon: Icon(Icons.arrow_downward_rounded)),
                  ButtonSegment(value: TransactionType.expense,
                      label: Text('Despesa'),
                      icon: Icon(Icons.arrow_upward_rounded)),
                  ButtonSegment(value: TransactionType.transfer,
                      label: Text('Transferência'),
                      icon: Icon(Icons.swap_horiz_rounded)),
                ],
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
              ),
              const SizedBox(height: 16),

              // Descricao
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Descrição *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 12),

              // Valor
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
                ],
                decoration: InputDecoration(
                  labelText: 'Valor (R\$) *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final d = double.tryParse(v.replaceAll(',', '.'));
                  if (d == null || d <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Categoria
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: InputDecoration(
                  labelText: 'Categoria *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: categories
                    .where((c) =>
                        c.type == 'both' ||
                        (_type == TransactionType.income &&
                            c.type == 'income') ||
                        (_type == TransactionType.expense &&
                            c.type == 'expense'))
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(children: [
                            Text(c.icon),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),

              // Data
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300)),
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text(
                  '${_date.day.toString().padLeft(2, "0")}/'
                  '${_date.month.toString().padLeft(2, "0")}/'
                  '${_date.year}',
                ),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate:  DateTime(2030),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 12),

              // Pago
              SwitchListTile(
                value: _isPaid,
                onChanged: (v) => setState(() => _isPaid = v),
                title: const Text('Já pago / recebido'),
                secondary: Icon(_isPaid
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300)),
              ),
              const SizedBox(height: 12),

              // Cartao
              if (_type == TransactionType.expense) ...[
                SwitchListTile(
                  value: _isCredit,
                  onChanged: (v) => setState(() => _isCredit = v),
                  title: const Text('Pagar no cartão'),
                  secondary: const Icon(Icons.credit_card_rounded),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300)),
                ),
                const SizedBox(height: 12),

                if (_isCredit) ...[
                  Row(children: [
                    const Text('Parcelas: ',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: _installments.toDouble(),
                        min: 1, max: 24, divisions: 23,
                        label: _installments == 1
                            ? 'À vista' : '${_installments}x',
                        onChanged: (v) =>
                            setState(() => _installments = v.toInt()),
                      ),
                    ),
                    Text(
                      _installments == 1 ? 'À vista' : '${_installments}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ],
              ],

              // Recorrencia
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrence,
                decoration: InputDecoration(
                  labelText: 'Recorrência',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.repeat_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                      value: RecurrenceType.none,
                      child: Text('Sem recorrência')),
                  DropdownMenuItem(
                      value: RecurrenceType.daily,   child: Text('Diária')),
                  DropdownMenuItem(
                      value: RecurrenceType.weekly,  child: Text('Semanal')),
                  DropdownMenuItem(
                      value: RecurrenceType.monthly, child: Text('Mensal')),
                  DropdownMenuItem(
                      value: RecurrenceType.yearly,  child: Text('Anual')),
                ],
                onChanged: (v) =>
                    setState(() => _recurrence = v ?? RecurrenceType.none),
              ),
              const SizedBox(height: 12),

              // Observacoes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Botao salvar
              FilledButton.icon(
                onPressed: _saving ? null : () => _save(categories),
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Salvando...' : 'Salvar Lançamento'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}