import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/profile_providers.dart';

/// Zona de perigo: trocar senha e sair da conta
class DangerZone extends ConsumerWidget {
  const DangerZone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      // Trocar senha
      ListTile(
        leading: const Icon(Icons.lock_reset_rounded),
        title: const Text('Trocar Senha'),
        subtitle: const Text('Alterar senha da conta',
            style: TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        onTap: () => _showChangePassword(context, ref),
      ),
      const Divider(height: 1, indent: 16),

      // Sair
      ListTile(
        leading: const Icon(Icons.logout_rounded,
            color: Colors.orange),
        title: const Text('Sair da Conta',
            style: TextStyle(color: Colors.orange)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        onTap: () => _confirmLogout(context),
      ),
    ],
  );

  void _showChangePassword(
      BuildContext context, WidgetRef ref) {
    final curCtrl  = TextEditingController();
    final nextCtrl = TextEditingController();
    final confCtrl = TextEditingController();

    showModalBottomSheet(
      context:       context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔐 Trocar Senha',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller:     curCtrl,
              obscureText:    true,
              decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller:  nextCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  prefixIcon: Icon(Icons.lock_rounded)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller:  confCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  prefixIcon: Icon(Icons.lock_rounded)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (nextCtrl.text != confCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Senhas não coincidem')));
                    return;
                  }
                  try {
                    await ref
                        .read(changePasswordProvider)
                        .call(curCtrl.text, nextCtrl.text);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text(
                                  '✅ Senha alterada com sucesso!')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erro: $e')));
                    }
                  }
                },
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Sair da conta?'),
        content: const Text(
            'Você será desconectado do DinDinVani&Nani.\n'
            'Seus dados ficam salvos na nuvem.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.orange),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}