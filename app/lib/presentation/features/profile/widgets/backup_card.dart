import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/profile_providers.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

/// Card de backup e restauracao
class BackupCard extends ConsumerWidget {
  const BackupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading    = ref.watch(backupLoadingProvider);
    final settingsAv = ref.watch(familySettingsProvider);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('💾', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text('Backup de Dados',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              settingsAv.value?.lastBackupAt != null
                  ? 'Último backup: '
                    '${_formatDate(settingsAv.value!.lastBackupAt!)}'
                  : 'Nenhum backup realizado ainda',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Exporte todos os seus dados financeiros em formato JSON. '
              'Guarde em nuvem (Drive, iCloud) para maior segurança.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading
                        ? null
                        : () => _doBackup(context, ref),
                    icon: loading
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Icon(
                            Icons.cloud_upload_rounded,
                            size: 16),
                    label: Text(
                        loading ? 'Exportando...' : 'Exportar'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doBackup(
      BuildContext context, WidgetRef ref) async {
    ref.read(backupLoadingProvider.notifier).state = true;
    try {
      final familyId = ref.read(currentFamilyIdProvider);
      final exporter = ref.read(exportBackupProvider);
      final json     = await exporter.call(familyId);

      final dir  = await getTemporaryDirectory();
      final now  = DateTime.now();
      final name =
          'dindin_backup_${now.year}${now.month.toString().padLeft(2,'0')}'
          '${now.day.toString().padLeft(2,'0')}.json';
      final file = File('${dir.path}/$name');
      await file.writeAsString(json, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'DinDinVani&Nani — Backup',
        text:    'Backup gerado em ${_formatDate(now)}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no backup: $e')));
      }
    } finally {
      ref.read(backupLoadingProvider.notifier).state = false;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/'
      '${dt.month.toString().padLeft(2,'0')}/'
      '${dt.year}';
}