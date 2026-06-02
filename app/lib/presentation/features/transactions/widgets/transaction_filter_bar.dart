// lib/presentation/features/transactions/widgets/transaction_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

class TransactionFilterBar extends ConsumerWidget {
  const TransactionFilterBar({super.key});

  static const _months = [
    'Jan','Fev','Mar','Abr','Mai','Jun',
    'Jul','Ago','Set','Out','Nov','Dez'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);

    return Column(
      children: [
        // Navegacao mes/ano
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () {
                final f = filter;
                final newMonth = f.month == 1 ? 12 : f.month - 1;
                final newYear  = f.month == 1 ? f.year - 1 : f.year;
                ref.read(transactionFilterProvider.notifier).state =
                    f.copyWith(month: newMonth, year: newYear);
              },
            ),
            Text(
              '${_months[filter.month - 1]} ${filter.year}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () {
                final f = filter;
                final newMonth = f.month == 12 ? 1 : f.month + 1;
                final newYear  = f.month == 12 ? f.year + 1 : f.year;
                ref.read(transactionFilterProvider.notifier).state =
                    f.copyWith(month: newMonth, year: newYear);
              },
            ),
          ],
        ),
        // Filtro por tipo
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _TypeChip(label: 'Todos',    value: null,                     current: filter.type),
              _TypeChip(label: 'Receitas', value: TransactionType.income,   current: filter.type),
              _TypeChip(label: 'Despesas', value: TransactionType.expense,  current: filter.type),
              _TypeChip(label: 'Transf.',  value: TransactionType.transfer, current: filter.type),
            ],
          ),
        ),
        // Barra de pesquisa
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar lançamento...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              isDense: true,
            ),
            onChanged: (v) {
              ref.read(transactionFilterProvider.notifier).state =
                  filter.copyWith(search: v.isEmpty ? null : v, clearSearch: v.isEmpty);
            },
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends ConsumerWidget {
  final String label;
  final TransactionType? value;
  final TransactionType? current;

  const _TypeChip({required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          final filter = ref.read(transactionFilterProvider);
          ref.read(transactionFilterProvider.notifier).state =
              filter.copyWith(type: value, clearType: value == null);
        },
      ),
    );
  }
}