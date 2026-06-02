// lib/presentation/features/dashboard/widgets/peace_score_widget.dart
import 'package:flutter/material.dart';

class PeaceScoreWidget extends StatelessWidget {
  final int score;
  const PeaceScoreWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80 ? Colors.green
        : score >= 60 ? Colors.orange
        : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Score Paz Financeira', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text('$score', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
          LinearProgressIndicator(value: score / 100, color: color,
              backgroundColor: color.withValues(alpha: 0.2)),
        ]),
      ),
    );
  }
}