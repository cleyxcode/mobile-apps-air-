import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _notifId = 0;

  // Track last notification to avoid spamming
  String? _lastNotifKey;
  DateTime? _lastNotifTime;

  /// Initialize the notification plugin and request permissions.
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request Android 13+ permission
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    // Request iOS permission
    if (Platform.isIOS) {
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Can handle navigation based on response.payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show a notification. Deduplicates by [key] within [cooldown].
  Future<void> show({
    required String title,
    required String body,
    String? payload,
    String? key,
    Duration cooldown = const Duration(seconds: 30),
  }) async {
    if (!_initialized) return;

    // Deduplicate: skip if same key sent recently
    if (key != null && _lastNotifKey == key && _lastNotifTime != null) {
      if (DateTime.now().difference(_lastNotifTime!) < cooldown) return;
    }

    _lastNotifKey = key;
    _lastNotifTime = DateTime.now();

    final androidDetails = AndroidNotificationDetails(
      'siram_pintar_channel',
      'Siram Pintar',
      channelDescription: 'Notifikasi penyiraman & sensor',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF10B981),
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: _notifId++,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Notify: soil is dry
  Future<void> notifyDrySoil(double moisture) async {
    await show(
      title: '🌵 Tanah Kering Terdeteksi!',
      body:
          'Kelembaban tanah ${moisture.toStringAsFixed(1)}% — KNN merekomendasikan penyiraman segera.',
      payload: 'dry_soil',
      key: 'dry_soil',
      cooldown: const Duration(minutes: 2),
    );
  }

  /// Notify: pump activated
  Future<void> notifyPumpOn() async {
    await show(
      title: '💧 Penyiraman Aktif',
      body: 'Pompa air telah dinyalakan. Tanaman sedang disiram.',
      payload: 'pump_on',
      key: 'pump_on',
      cooldown: const Duration(minutes: 1),
    );
  }

  /// Notify: pump deactivated
  Future<void> notifyPumpOff() async {
    await show(
      title: '✅ Penyiraman Selesai',
      body: 'Pompa air telah dimatikan.',
      payload: 'pump_off',
      key: 'pump_off',
      cooldown: const Duration(seconds: 30),
    );
  }

  /// Notify: optimal soil condition
  Future<void> notifyOptimalSoil(double moisture) async {
    await show(
      title: '🌿 Kondisi Tanah Optimal',
      body:
          'Kelembaban tanah ${moisture.toStringAsFixed(1)}% — kondisi ideal untuk tanaman.',
      payload: 'optimal',
      key: 'optimal',
      cooldown: const Duration(minutes: 10),
    );
  }

  /// Notify: connection lost
  Future<void> notifyOffline() async {
    await show(
      title: '⚠️ Koneksi Terputus',
      body: 'Tidak dapat terhubung ke sensor. Periksa koneksi jaringan Anda.',
      payload: 'offline',
      key: 'offline',
      cooldown: const Duration(minutes: 5),
    );
  }
}
