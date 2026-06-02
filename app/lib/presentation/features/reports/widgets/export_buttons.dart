import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../providers/report_providers.dart';

class ExportButtons extends ConsumerWidget {
  const ExportButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ExportBtn(
          icon:    Icons.picture_as_pdf,
          label:   'PDF',
          color:   Colors.red,
          isPdf:   true,
          ref:     ref,
        ),
        const SizedBox(width: 12),
        _ExportBtn(
          icon:    Icons.table_chart,
          label:   'CSV',
          color:   Colors.green,
          isPdf:   false,
          ref:     ref,
        ),
      ],
    );
  }
}

class _ExportBtn extends ConsumerStatefulWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final bool     isPdf;
  final WidgetRef ref;

  const _ExportBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isPdf,
    required this.ref,
  });

  @override
  ConsumerState<_ExportBtn> createState() => _ExportBtnState();
}

class _ExportBtnState extends ConsumerState<_ExportBtn> {
  bool _loading = false;

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      final exporter = ref.read(exportReportProvider);
      final filter   = ref.read(reportFilterProvider);
      final familyId = ref.read(currentFamilyIdProvider);

      if (widget.isPdf) {
        await exporter.pdf(familyId, filter);
      } else {
        await exporter.csv(familyId, filter);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.label} exportado com sucesso!'),
            backgroundColor: widget.color,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _export,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: _loading
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(widget.icon),
      label: Text(widget.label),
    );
  }
}