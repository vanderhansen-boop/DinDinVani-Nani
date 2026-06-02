import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── .env ──────────────────────────────────────────────────────
  await dotenv.load(fileName: '.env');

  // ── Supabase ──────────────────────────────────────────────────
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  // ── Firebase ──────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background handler precisa ser registrado antes do runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: DinDinApp(),
    ),
  );
}

class DinDinApp extends ConsumerWidget {
  const DinDinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicia servico de notificacoes
    ref.watch(notificationServiceProvider).init();

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DinDinVani&Nani',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      routerConfig: router,
    );
  }
}