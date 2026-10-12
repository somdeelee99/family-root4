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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Logger(printer: PrettyPrinter(methodCount: 0))
      .i('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;

  // 1. Initialize Firebase first.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseReady = true;

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('BOOT: Firebase OK');
  } catch (e, s) {
    debugPrint('BOOT ERROR: Firebase: $e\n$s');
  }

  // 2. Initialize notifications independently.
  if (firebaseReady) {
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await NotificationService.instance.init().timeout(
        const Duration(seconds: 15),
      );

      debugPrint('BOOT: Notifications OK');
    } catch (e, s) {
      debugPrint('BOOT ERROR: Notifications: $e\n$s');
    }
  }

  // 3. Set screen orientation.
  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } catch (e, s) {
    debugPrint('BOOT ERROR: Orientation: $e\n$s');
  }

  // 4. ThemeService is required by FamilyRootApp.
  try {
    await Get.putAsync(() => ThemeService().init())
        .timeout(const Duration(seconds: 15));

    debugPrint('BOOT: ThemeService OK');
  } catch (e, s) {
    debugPrint('BOOT ERROR: ThemeService: $e\n$s');

    runApp(
      const BootstrapErrorApp(
        message: 'Cannot initialize app theme. Please restart the app.',
      ),
    );
    return;
  }

  // 5. Initialize other services independently.
  try {
    await Get.putAsync(() => ConnectivityService().init())
        .timeout(const Duration(seconds: 15));

    debugPrint('BOOT: ConnectivityService OK');
  } catch (e, s) {
    debugPrint('BOOT ERROR: ConnectivityService: $e\n$s');
  }

  if (firebaseReady) {
    try {
      await Get.putAsync(() => AuthService().init())
          .timeout(const Duration(seconds: 15));

      debugPrint('BOOT: AuthService OK');
    } catch (e, s) {
      debugPrint('BOOT ERROR: AuthService: $e\n$s');
    }
  }

  // 6. Start the app.
  debugPrint('BOOT: runApp');
  runApp(const FamilyRootApp());
}

class BootstrapErrorApp extends StatelessWidget {
  final String message;

  const BootstrapErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Family Root could not start',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
