import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/family_settings.dart';
import '../providers/profile_providers.dart';

/// Seletor visual de tema e esquema de cores
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modo claro/escuro/sistema
        const Text('Modo',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedButton<AppThemeMode>(
          segments: const [
            ButtonSegment(
                value: AppThemeMode.light,
                icon: Icon(Icons.light_mode_rounded),
                label: Text('Claro')),
            ButtonSegment(
                value: AppThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded),
                label: Text('Auto')),
            ButtonSegment(
                value: AppThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded),
                label: Text('Escuro')),
          ],
          selected: {current.mode},
          onSelectionChanged: (s) {
            ref.read(themeSettingsProvider.notifier).state =
                (mode: s.first, scheme: current.scheme);
          },
        ),
        const SizedBox(height: 16),

        // Esquema de cor
        const Text('Cor do App',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ColorSchemeType.values.map((scheme) {
            final isSelected = current.scheme == scheme;
            final color      = _colorFor(scheme);
            return GestureDetector(
              onTap: () => ref
                  .read(themeSettingsProvider.notifier)
                  .state = (mode: current.mode, scheme: scheme),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color:  color,
                  shape:  BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(
                          color:      color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1)]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _colorFor(ColorSchemeType scheme) {
    switch (scheme) {
      case ColorSchemeType.pink:   return const Color(0xFFE91E8C);
      case ColorSchemeType.blue:   return const Color(0xFF1565C0);
      case ColorSchemeType.green:  return const Color(0xFF2E7D32);
      case ColorSchemeType.purple: return const Color(0xFF6A1B9A);
      case ColorSchemeType.orange: return const Color(0xFFE65100);
      case ColorSchemeType.teal:   return const Color(0xFF00695C);
    }
  }
}
