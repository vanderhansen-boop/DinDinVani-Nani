import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double size;
  const AuthLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'DinDinVani&Nani',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Financas em paz, a dois',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
