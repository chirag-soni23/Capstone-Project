import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default',
    'General Notifications',
    description: 'General app notifications',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> init() async {
    // ================= PERMISSION =================

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // ================= LOCAL NOTIFICATION =================

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // ================= CHANNEL =================

    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // ================= FCM TOPIC =================

    await messaging.subscribeToTopic('users');

    // ================= FOREGROUND =================

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Notification: '
        '${message.notification?.title} - '
        '${message.notification?.body}',
      );

      showNotification(message);
    });

    // ================= NOTIFICATION CLICK =================

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'Notification opened: '
        '${message.notification?.title}',
      );
    });

    // ================= TERMINATED APP =================

    final RemoteMessage? initialMessage = await messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'Opened from notification: '
        '${initialMessage.notification?.title}',
      );
    }
  }

  // ================= SHOW NOTIFICATION =================

  static Future<void> showNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'GlowCare',
      body: notification.body ?? '',
      notificationDetails: notificationDetails,
      payload: message.data['type'],
    );
  }
}

// ================= BACKGROUND HANDLER =================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    'Background notification: '
    '${message.notification?.title}',
  );
}
