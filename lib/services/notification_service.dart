import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/tip_model.dart';
import '../services/local_storage.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final LocalStorageService _localStorageService;

  NotificationService(this._localStorageService);

  Future<void> init() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    final tip = _localStorageService.getRandomTip();
    if (tip == null) {
      debugPrint('No tip available for notification');
      return;
    }

    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final finalScheduledDate = scheduledDate.isBefore(now) ? scheduledDate.add(Duration(days: 1)) : scheduledDate;

    await _notificationsPlugin.zonedSchedule(
      0,
      'Daily Security Tip'.tr(),
      tip.titleEn,
      finalScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_tip_channel',
          'Daily Tips',
          channelDescription: 'Daily security tips notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('Scheduled notification for ${finalScheduledDate.toString()}');
  }

  Future<void> cancelNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled');
  }
}