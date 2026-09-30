import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// ຈັດການການແຈ້ງເຕືອນ (FCM + Local Notification)
/// - ເມື່ອມີການແຊັດຫາກັນ ຈະມີການແຈ້ງເຕືອນໄປຫາຜູ້ຮັບ
/// - ຮອງຮັບທັງໂໝດ foreground ແລະ background
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'family_root_channel',
    'Family Root',
    description: 'ແຈ້ງເຕືອນຂໍ້ຄວາມ ແລະ ການເຄື່ອນໄຫວໃນຄອບຄົວ',
    importance: Importance.high,
  );

  bool _initialized = false;
  String? _token;

  String? get token => _token;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ຂໍອະນຸຍາດ + ເອົາ token
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _token = await FirebaseMessaging.instance.getToken();
      FirebaseMessaging.instance.onTokenRefresh
          .listen((value) => _token = value);
    } catch (e) {
      _log.w('FCM ບໍ່ສາມາດເລີ່ມຕົ້ນໄດ້: $e');
    }

    // Local notification
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      settings: InitializationSettings(android: androidInit, iOS: iosInit),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Foreground handler
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _log.i('ເປີດແອັບຈາກແຈ້ງເຕືອນ: ${message.data}'));

    if (kDebugMode && Platform.isAndroid) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await showLocal(
      title: notification.title ?? 'Family Root',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    await _local.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// ສະໝັກຫົວຂໍ້ສຳລັບການແຈ້ງເຕືອນແຊັດຂອງຜູ້ໃຊ້
  Future<void> subscribeToFamily(String familyId) async {
    await FirebaseMessaging.instance.subscribeToTopic('family_$familyId');
  }

  Future<void> unsubscribeFromFamily(String familyId) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('family_$familyId');
  }
}
