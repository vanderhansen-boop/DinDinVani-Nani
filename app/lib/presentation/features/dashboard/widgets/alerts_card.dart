import 'package:flutter/material.dart';

class AlertsCard extends StatelessWidget {
  final List<String> alerts;
  const AlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Alertas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(),
            ...alerts.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
