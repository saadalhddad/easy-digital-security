
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 4)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String languageCode;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  String? notificationTime; // تغيير إلى String بدلاً من TimeOfDay

  @HiveField(4)
  double fontSizeScale;

  @HiveField(5)
  bool onboardingCompleted;

  UserSettings({
    this.isDarkMode = false,
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.notificationTime = '9:00', // تنسيق نصي (HH:mm)
    this.fontSizeScale = 1.0,
    this.onboardingCompleted = false,
  });

  // تحويل notificationTime إلى TimeOfDay عند الحاجة
  TimeOfDay getNotificationTimeOfDay() {
    if (notificationTime == null) return const TimeOfDay(hour: 9, minute: 0);
    final parts = notificationTime!.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // تعيين notificationTime من TimeOfDay
  void setNotificationTimeOfDay(TimeOfDay time) {
    notificationTime = '${time.hour}:${time.minute}';
  }

  UserSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? notificationsEnabled,
    TimeOfDay? notificationTime,
    double? fontSizeScale,
    bool? onboardingCompleted,
  }) {
    final newSettings = UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
    if (notificationTime != null) {
      newSettings.setNotificationTimeOfDay(notificationTime);
    } else {
      newSettings.notificationTime = this.notificationTime;
    }
    return newSettings;
  }

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'languageCode': languageCode,
    'notificationsEnabled': notificationsEnabled,
    'notificationTime': notificationTime,
    'fontSizeScale': fontSizeScale,
    'onboardingCompleted': onboardingCompleted,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      languageCode: json['languageCode'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationTime: json['notificationTime'] as String? ?? '9:00',
      fontSizeScale: json['fontSizeScale'] as double? ?? 1.0,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}
