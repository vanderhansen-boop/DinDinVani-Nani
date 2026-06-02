import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/family_settings.dart';
import 'providers/profile_providers.dart';
import 'widgets/couple_avatar_header.dart';
import 'widgets/theme_selector.dart';
import 'widgets/philosophy_toggles.dart';
import 'widgets/backup_card.dart';
import 'widgets/danger_zone.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync       = ref.watch(currentProfileProvider);
    final partnerAsync  = ref.watch(partnerProfileProvider);
    final settingsAsync = ref.watch(familySettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentProfileProvider);
            ref.invalidate(partnerProfileProvider);
            ref.invalidate(familySettingsProvider);
          },
          child: meAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (me) => CustomScrollView(
              slivers: [
                // ── Header casal
                SliverToBoxAdapter(
                  child: settingsAsync.when(
                    loading: () => const SizedBox(height: 160),
                    error:   (e, _) => const SizedBox.shrink(),
                    data: (settings) => CoupleAvatarHeader(
                      me:          me,
                      partner:     partnerAsync.value,
                      familyName:  settings.familyName,
                      familyEmoji: settings.familyEmoji,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Meu Perfil
                        _SectionHeader(
                            title: '👤 Meu Perfil',
                            onEdit: () =>
                                _showEditProfile(context, ref, me)),
                        const SizedBox(height: 8),
                        _ProfileInfoCard(me: me),
                        const SizedBox(height: 20),

                        // ── Aparência
                        const _SectionHeader(title: '🎨 Aparência'),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16)),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: ThemeSelector(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Filosofia financeira
                        const _SectionHeader(
                            title: '🧠 Filosofia Financeira'),
                        const SizedBox(height: 8),
                        settingsAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) => Text('Erro: $e'),
                          data: (settings) => PhilosophyToggles(
                              settings: settings),
                        ),
                        const SizedBox(height: 20),

                        // ── Nome da familia
                        settingsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error:   (e, _) => const SizedBox.shrink(),
                          data: (settings) => Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                  title: '💑 Configurações do Casal',
                                  onEdit: () =>
                                      _showEditFamily(
                                          context, ref, settings)),
                              const SizedBox(height: 8),
                              _FamilyInfoCard(settings: settings),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // ── Backup
                        const _SectionHeader(title: '💾 Backup'),
                        const SizedBox(height: 8),
                        const BackupCard(),
                        const SizedBox(height: 20),

                        // ── Zona de perigo
                        const _SectionHeader(
                            title: '⚠️ Conta',
                            color: Colors.orange),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16)),
                          child: const DangerZone(),
                        ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom sheets de edição
  void _showEditProfile(
      BuildContext context, WidgetRef ref, dynamic me) {
    final nameCtrl =
        TextEditingController(text: me.name);
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Editar Perfil',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon:
                      Icon(Icons.person_rounded)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref
                      .read(updateProfileProvider)
                      .call(me.copyWith(name: nameCtrl.text));
                  ref.invalidate(currentProfileProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFamily(BuildContext context, WidgetRef ref,
      FamilySettings settings) {
    final nameCtrl =
        TextEditingController(text: settings.familyName);
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💑 Editar Casal',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nome do casal',
                  prefixIcon:
                      Icon(Icons.favorite_rounded)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref
                      .read(updateFamilySettingsProvider)
                      .call(settings.copyWith(
                          familyName: nameCtrl.text));
                  ref.invalidate(familySettingsProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Widgets auxiliares
// ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String    title;
  final VoidCallback? onEdit;
  final Color?    color;
  const _SectionHeader({
      required this.title, this.onEdit, this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color)),
      const Spacer(),
      if (onEdit != null)
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded, size: 14),
          label: const Text('Editar',
              style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact),
        ),
    ],
  );
}

class _ProfileInfoCard extends StatelessWidget {
  final dynamic me;
  const _ProfileInfoCard({required this.me});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoRow(
              icon: Icons.person_rounded,
              label: 'Nome',
              value: me.name),
          const Divider(height: 16),
          _InfoRow(
              icon: Icons.email_rounded,
              label: 'E-mail',
              value: me.email),
          const Divider(height: 16),
          _InfoRow(
              icon: Icons.emoji_emotions_rounded,
              label: 'Avatar',
              value: me.emoji),
        ],
      ),
    ),
  );
}

class _FamilyInfoCard extends StatelessWidget {
  final FamilySettings settings;
  const _FamilyInfoCard({required this.settings});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoRow(
              icon: Icons.favorite_rounded,
              label: 'Nome do casal',
              value: settings.familyName),
          const Divider(height: 16),
          _InfoRow(
              icon: Icons.palette_rounded,
              label: 'Tema',
              value: settings.themeLabel),
          const Divider(height: 16),
          _InfoRow(
              icon: Icons.color_lens_rounded,
              label: 'Cor',
              value: settings.schemeLabel),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _InfoRow({
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500)),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600)),
    ],
  );
}