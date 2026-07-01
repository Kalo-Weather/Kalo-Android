import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  late final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _alertChannelId = 'weather_alerts';
  static const String _alertChannelName = 'Weather Alerts';
  static const String _alertChannelDescription = 'Severe weather alerts for your location';
  static const String _nowBarChannelId = 'weather_now_bar';
  static const String _nowBarChannelName = 'Now Bar';
  static const String _nowBarChannelDescription = 'Weather info on lock screen Now Bar';
  static const int _nowBarNotificationId = 9999;

  final Set<int> _notifiedAlertIds = {};

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _plugin = FlutterLocalNotificationsPlugin();
    await _plugin.initialize(
      settings: initSettings,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _alertChannelId,
          _alertChannelName,
          description: _alertChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _nowBarChannelId,
          _nowBarChannelName,
          description: _nowBarChannelDescription,
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
    }

    _initialized = true;
  }

  Future<void> showWeatherAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _alertChannelId,
      _alertChannelName,
      channelDescription: _alertChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Color(0xFFFF6B35),
      icon: '@drawable/ic_notification',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> showNowBarWeather({
    required String temp,
    required String emoji,
    required String location,
    required String condition,
  }) async {
    if (!_initialized) return;

    final androidDetails = AndroidNotificationDetails(
      _nowBarChannelId,
      _nowBarChannelName,
      channelDescription: _nowBarChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      usesChronometer: false,
      color: const Color(0xFFFF6B35),
      icon: '@drawable/ic_notification',
      category: AndroidNotificationCategory.status,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: _nowBarNotificationId,
      title: '$temp $emoji',
      body: '$location — $condition',
      notificationDetails: details,
    );
  }

  bool hasNotified(int alertId) => _notifiedAlertIds.contains(alertId);

  void markNotified(int alertId) => _notifiedAlertIds.add(alertId);

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
