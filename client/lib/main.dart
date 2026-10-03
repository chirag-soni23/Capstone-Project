import 'package:client/firebase_options.dart';
import 'package:client/screen/MainScreen.dart';
import 'package:client/services/api_service.dart';
import 'package:client/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await NotificationService.init();

  ApiService.init();

  runApp(const GlowCareApp());
}

class GlowCareApp extends StatelessWidget {
  const GlowCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlowCare',
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}