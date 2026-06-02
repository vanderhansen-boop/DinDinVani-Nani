import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Background handler (top-level obrigatorio) ───────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Supabase nao precisa init aqui — apenas logamos
  print('[FCM Background] ${message.notification?.title}');
}

// ─── Canal Android ────────────────────────────────────────────────
const AndroidNotificationChannel kDefaultChannel = AndroidNotificationChannel(
  'dindin_default',
  'DinDinVani — Alertas',
  description: 'Notificacoes financeiras do DinDinVani&Nani',
  importance: Importance.high,
  playSound: true,
);

// ─── Plugin local ─────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ── Init completo ──────────────────────────────────────────────
  Future<void> init() async {
    // Registra background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Permissoes
    await _requestPermission();

    // Canal Android
    await _createAndroidChannel();

    // Init local notifications
    await _initLocalNotifications();

    // Listeners foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Tap em notificacao (app em background/fechado)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Token
    final token = await getToken();
    print('[FCM] Token: $token');
  }

  // ── Permissoes ────────────────────────────────────────────────
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('[FCM] Permissao: ${settings.authorizationStatus}');
  }

  // ── Canal Android ─────────────────────────────────────────────
  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kDefaultChannel);
  }

  // ── Init local notifications ──────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: initAndroid,
      iOS: initDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // ── Mensagem em foreground ────────────────────────────────────
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kDefaultChannel.id,
          kDefaultChannel.name,
          channelDescription: kDefaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'],
    );
  }

  // ── Tap na notificacao ────────────────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    // TODO: navegar para rota em response.payload
    print('[FCM] Tap: ${response.payload}');
  }

  // ── App aberto via notificacao ────────────────────────────────
  void _onMessageOpenedApp(RemoteMessage message) {
    print('[FCM] App aberto via: ${message.notification?.title}');
    // TODO: navegar para rota em message.data['route']
  }

  // ── Token FCM ─────────────────────────────────────────────────
  Future<String?> getToken() async => await _fcm.getToken();

  // ── Notificacao local manual (alertas do app) ─────────────────
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kDefaultChannel.id,
          kDefaultChannel.name,
          channelDescription: kDefaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}

// ─── Provider Riverpod ────────────────────────────────────────────
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});