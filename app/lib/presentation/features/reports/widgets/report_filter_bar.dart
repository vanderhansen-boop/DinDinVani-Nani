import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_providers.dart';

class ReportFilterBar extends ConsumerWidget {
  const ReportFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Período: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _Chip(
            label: '3 meses',
            selected: filter.period == ReportPeriod.threeMonths,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setPeriod(ReportPeriod.threeMonths),
          ),
          const SizedBox(width: 6),
          _Chip(
            label: '6 meses',
            selected: filter.period == ReportPeriod.sixMonths,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setPeriod(ReportPeriod.sixMonths),
          ),
          const SizedBox(width: 6),
          _Chip(
            label: '12 meses',
            selected: filter.period == ReportPeriod.twelveMonths,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setPeriod(ReportPeriod.twelveMonths),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}