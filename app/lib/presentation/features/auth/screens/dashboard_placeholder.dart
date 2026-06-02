import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

/// Tela placeholder do dashboard ate o Script 21 implementar a versao real.
class DashboardPlaceholderScreen extends ConsumerWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authNotifierProvider);
    final name = state is AuthAuthenticated ? state.user.name : 'usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('DinDinVani&Nani'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text("Bem-vindo(a), $name!", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text('Dashboard sera implementado no Script 21'),
          ],
        ),
      ),
    );
  }
}
