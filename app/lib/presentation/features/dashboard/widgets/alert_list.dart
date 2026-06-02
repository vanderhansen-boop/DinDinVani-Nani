// lib/presentation/features/dashboard/widgets/alert_list.dart
import 'package:flutter/material.dart';

class AlertList extends StatelessWidget {
  final List<String> alerts;
  const AlertList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.orange.shade50,
      child: Column(
        children: alerts.map((a) => ListTile(
          leading: const Icon(Icons.warning_amber, color: Colors.orange),
          title: Text(a, style: const TextStyle(fontSize: 13)),
          dense: true,
        )).toList(),
      ),
    );
  }
}