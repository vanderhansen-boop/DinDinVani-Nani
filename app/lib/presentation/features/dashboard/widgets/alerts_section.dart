// lib/presentation/features/dashboard/widgets/alerts_section.dart
import 'package:flutter/material.dart';

class AlertsSection extends StatelessWidget {
  final List<String> alerts;

  const AlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.green.shade50,
        child: const ListTile(
          leading: Icon(Icons.check_circle_rounded, color: Colors.green),
          title: Text('Tudo certo! Nenhum alerta.', style: TextStyle(color: Colors.green)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('Alertas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        ...alerts.map((alert) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.orange.shade50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            title: Text(alert, style: const TextStyle(fontSize: 13)),
          ),
        )),
      ],
    );
  }
}