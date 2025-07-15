import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:easy_localization/easy_localization.dart';
import '../models/tip_model.dart';
import '../services/local_storage.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final LocalStorageService _localStorageService;

  NotificationService(this._localStorageService);

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      final initialized = await _notificationsPlugin.initialize(initializationSettings);
      if (!initialized!) {
        throw Exception('Failed to initialize notifications');
      }
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      throw Exception('Notification initialization failed: $e');
    }
  }

  Future<void> scheduleDailyTipNotification(BuildContext context, String title, String body) async {
    try {
      final now = DateTime.now();
      final time = TimeOfDay(hour: now.hour, minute: now.minute + 1); // Schedule 1 minute later for testing
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
        'Daily Security Tip'.tr(context: context),
        body,
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
      debugPrint('Scheduled daily tip notification for $finalScheduledDate with title: $title');
    } catch (e) {
      debugPrint('Error scheduling daily tip notification: $e');
      throw Exception('Failed to schedule daily tip notification: $e');
    }
  }

  Future<void> scheduleDailyNotification(BuildContext context, TimeOfDay time) async {
    try {
      final tip = _localStorageService.getRandomTip();
      if (tip == null) {
        debugPrint('No tip available for notification');
        throw Exception('No tip available for notification');
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

      final title = EasyLocalization.of(context)!.locale.languageCode == 'ar' ? tip.titleAr : tip.titleEn;
      final body = EasyLocalization.of(context)!.locale.languageCode == 'ar' ? tip.contentAr : tip.contentEn;

      await _notificationsPlugin.zonedSchedule(
        0,
        'Daily Security Tip'.tr(context: context),
        body,
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
      debugPrint('Scheduled daily notification for $finalScheduledDate with title: $title');
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
      throw Exception('Failed to schedule daily notification: $e');
    }
  }

  Future<void> scheduleQuizCompletionNotification(BuildContext context, int score, int total, String quizTitle) async {
    try {
      final now = DateTime.now();
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute + 1, // Schedule 1 minute later for immediate feedback
      );

      final message = 'You scored $score out of $total in "$quizTitle". Keep learning!'.tr(context: context, args: ['$score', '$total', quizTitle]);

      await _notificationsPlugin.zonedSchedule(
        1,
        'Quiz Completed'.tr(context: context),
        message,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'quiz_completion_channel',
            'Quiz Completions',
            channelDescription: 'Notifications for quiz completion',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled quiz completion notification for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling quiz completion notification: $e');
      throw Exception('Failed to schedule quiz completion notification: $e');
    }
  }

  Future<void> schedulePasswordCheckNotification(BuildContext context, String strength) async {
    try {
      final now = DateTime.now();
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute + 1, // Schedule 1 minute later for immediate feedback
      );

      final languageCode = EasyLocalization.of(context)!.locale.languageCode;
      final message = languageCode == 'ar'
          ? 'فحص كلمة المرور: قوتها $strength. تحقق من النصائح لتحسينها!'.tr(context: context)
          : 'Password check: Strength is $strength. Check tips to improve!'.tr(context: context);

      await _notificationsPlugin.zonedSchedule(
        2,
        'Password Strength Check'.tr(context: context),
        message,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'password_check_channel',
            'Password Checks',
            channelDescription: 'Notifications for password strength checks',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled password check notification for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling password check notification: $e');
      throw Exception('Failed to schedule password check notification: $e');
    }
  }

  Future<void> cancelNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
      throw Exception('Failed to cancel notifications: $e');
    }
  }
}