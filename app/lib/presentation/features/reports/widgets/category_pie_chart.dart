import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../domain/entities/monthly_summary.dart';

/// Pizza de despesas por categoria (top 5 + outros)
class CategoryPieChart extends StatefulWidget {
  final MonthlySummary summary;
  const CategoryPieChart({super.key, required this.summary});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touched = -1;

  static const _colors = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF546E7A),
  ];

  @override
  Widget build(BuildContext context) {
    final top   = widget.summary.topCategories;
    final total = top.fold(0.0, (a, b) => a + b.value);
    if (total <= 0) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (ev, resp) {
                  setState(() {
                    if (!ev.isInterestedForInteractions ||
                        resp?.touchedSection == null) {
                      _touched = -1;
                      return;
                    }
                    _touched = resp!
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(top.length, (i) {
                final isTouched = i == _touched;
                final pct = (top[i].value / total * 100);
                return PieChartSectionData(
                  color:     _colors[i % _colors.length],
                  value:     top[i].value,
                  title:     '${pct.toStringAsFixed(1)}%',
                  radius:    isTouched ? 70 : 56,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 13 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legenda
        Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: List.generate(top.length, (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _colors[i % _colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${top[i].key}  ${top[i].value.toBRL}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          )),
        ),
      ],
    );
  }
}