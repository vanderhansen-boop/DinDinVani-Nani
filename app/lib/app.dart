import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'domain/entities/family_settings.dart';
import 'presentation/router/app_router.dart';

class DinDinApp extends ConsumerWidget {
  const DinDinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Esquema padrao do casal (sera ligado ao family_settings depois)
    const scheme = ColorSchemeType.pink;

    return MaterialApp.router(
      title: 'DinDinVani&Nani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(scheme),
      darkTheme: AppTheme.dark(scheme),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
