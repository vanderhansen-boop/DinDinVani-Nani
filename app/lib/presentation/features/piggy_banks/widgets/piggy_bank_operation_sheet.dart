import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/piggy_bank.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../providers/piggy_bank_providers.dart';

class PiggyBankOperationSheet extends ConsumerStatefulWidget {
  final PiggyBank piggyBank;
  final bool      isDeposit;

  const PiggyBankOperationSheet({
    super.key,
    required this.piggyBank,
    required this.isDeposit,
  });

  @override
  ConsumerState<PiggyBankOperationSheet> createState() =>
      _PiggyBankOperationSheetState();
}

class _PiggyBankOperationSheetState
    extends ConsumerState<PiggyBankOperationSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  bool  _loading    = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Informe um valor válido')));
      return;
    }
    if (!widget.isDeposit && amount > widget.piggyBank.currentBalance) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saldo insuficiente na caixinha')));
      return;
    }
    setState(() => _loading = true);
    try {
      final userId  = Supabase.instance.client.auth.currentUser!.id;
      final op      = ref.read(operatePiggyBankProvider);
      final desc    = _descCtrl.text.trim().isEmpty
          ? (widget.isDeposit ? 'Depósito manual' : 'Retirada manual')
          : _descCtrl.text.trim();

      if (widget.isDeposit) {
        await op.deposit(widget.piggyBank.id, amount, desc, userId);
      } else {
        await op.withdraw(widget.piggyBank.id, amount, desc, userId);
      }
      ref.invalidate(piggyBankListProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.isDeposit;
    final color     = isDeposit ? const Color(0xFF1565C0) : Colors.red;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),

            // Titulo
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(
                      isDeposit ? Icons.add_rounded : Icons.remove_rounded,
                      color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isDeposit ? 'Depositar em' : 'Retirar de',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(widget.piggyBank.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Spacer(),
                Text('Saldo: ${widget.piggyBank.currentBalance.toBRL}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 20),

            // Campo valor
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0,00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Descricao
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(
                hintText: isDeposit ? 'Descrição (ex: salário)' : 'Motivo da retirada',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),

            // Botao
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                label: Text(_loading
                    ? 'Processando...'
                    : isDeposit ? 'Confirmar Depósito' : 'Confirmar Retirada',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
