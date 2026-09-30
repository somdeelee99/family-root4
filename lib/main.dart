import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'app/app.dart';
import 'app/core/services/auth_service.dart';
import 'app/core/services/connectivity_service.dart';
import 'app/core/services/notification_service.dart';
import 'app/core/services/theme_service.dart';
import 'firebase_options.dart';

/// Handler ສຳລັບຂໍ້ຄວາມທີ່ມາເມື່ອແອັບຢູ່ background/terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger(printer: PrettyPrinter(methodCount: 0))
      .i('ແຈ້ງເຕືອນພາຍນອກແອັບ: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Firebase ----
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ---- Crashlytics: ຈັບຂໍ້ຜິດພາດທັງໝົດ ----
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  // ---- ແຈ້ງເຕືອນ ----
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.instance.init();

  // ---- ຕັ້ງຄ່າໜ້າຈໍ ----
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ---- Services ----
  await Get.putAsync(() => ThemeService().init());
  await Get.putAsync(() => ConnectivityService().init());
  await Get.putAsync(() => AuthService().init());

  runApp(const FamilyRootApp());
}
