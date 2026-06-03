// lib/presentation/features/dashboard/widgets/peace_score_card.dart
import 'package:flutter/material.dart';

class PeaceScoreCard extends StatelessWidget {
  final int score;

  const PeaceScoreCard({super.key, required this.score});

  Color get _color {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String get _label {
    if (score >= 80) return 'Ótimo! Casal em paz financeira 💚';
    if (score >= 50) return 'Atenção! Há pontos a melhorar 🟡';
    return 'Alerta! Risco financeiro 🔴';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 7,
                    color: _color,
                    backgroundColor: _color.withValues(alpha: 0.2),
                  ),
                ),
                Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: _color, fontSize: 16)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Score Paz Financeira', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(_label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
