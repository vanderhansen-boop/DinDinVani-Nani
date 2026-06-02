import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/family_settings.dart';
import '../providers/profile_providers.dart';

/// Toggles para ligar/desligar OD, CF e CPI
class PhilosophyToggles extends ConsumerWidget {
  final FamilySettings settings;
  const PhilosophyToggles({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _PhilosophyTile(
          emoji:    '📅',
          title:    'Orçamento Defasado (OD)',
          subtitle: 'Renda de M define orçamento de M+${settings.odMonthsDelay}',
          value:    settings.enableOD,
          color:    Colors.blue,
          onChanged: (v) => _update(ref, settings.copyWith(enableOD: v)),
        ),
        _PhilosophyTile(
          emoji:    '💳',
          title:    'Caixinha de Fatura (CF)',
          subtitle: 'Reserva automática para cada compra no cartão',
          value:    settings.enableCF,
          color:    Colors.green,
          onChanged: (v) => _update(ref, settings.copyWith(enableCF: v)),
        ),
        _PhilosophyTile(
          emoji:    '📦',
          title:    'Parcela Integral (CPI)',
          subtitle: 'Guarda o total parcelado imediatamente',
          value:    settings.enableCPI,
          color:    Colors.purple,
          onChanged: (v) => _update(ref, settings.copyWith(enableCPI: v)),
        ),
      ],
    );
  }

  void _update(WidgetRef ref, FamilySettings updated) {
    ref.read(updateFamilySettingsProvider).call(updated);
  }
}

class _PhilosophyTile extends StatelessWidget {
  final String   emoji;
  final String   title;
  final String   subtitle;
  final bool     value;
  final Color    color;
  final ValueChanged<bool> onChanged;

  const _PhilosophyTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: value
          ? color.withOpacity(0.06)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: value
            ? color.withOpacity(0.25)
            : Colors.grey.shade200,
      ),
    ),
    child: SwitchListTile(
      secondary: Text(emoji,
          style: const TextStyle(fontSize: 22)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500)),
      value:     value,
      onChanged: onChanged,
      activeColor: color,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 2),
    ),
  );
}