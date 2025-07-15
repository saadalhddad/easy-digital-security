import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/main.dart';
import 'package:easy_digital_security/screens/home_screen.dart';
import 'package:easy_digital_security/screens/learn_screen.dart';
import 'package:easy_digital_security/screens/quiz_screen.dart';
import 'package:easy_digital_security/screens/tools_screen.dart';
import 'package:easy_digital_security/services/notification_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart'; // Assuming Provider for theme management

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyNotifications = false;
  double _fontSize = 16.0;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled = localStorageService.getSetting('dailyNotifications', defaultValue: false);
    final fontSize = localStorageService.getSetting('fontSize', defaultValue: 16.0);
    final notificationTime = localStorageService.getSetting('notificationTime', defaultValue: '09:00');
    setState(() {
      _dailyNotifications = notificationsEnabled;
      _fontSize = fontSize;
      _notificationTime = TimeOfDay(
        hour: int.parse(notificationTime.split(':')[0]),
        minute: int.parse(notificationTime.split(':')[1]),
      );
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _dailyNotifications = value;
    });
    await localStorageService.saveSetting('dailyNotifications', value);
    if (notificationService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification service not initialized.'.tr())),
      );
      return;
    }
    if (value) {
      await notificationService!.scheduleDailyNotification(_notificationTime);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily notifications enabled.'.tr())),
      );
    } else {
      await notificationService!.cancelNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily notifications disabled.'.tr())),
      );
    }
  }

  Future<void> _selectNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      await localStorageService.saveSetting('notificationTime', '${picked.hour}:${picked.minute}');
      if (_dailyNotifications && notificationService != null) {
        await notificationService!.scheduleDailyNotification(picked);
      }
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    await context.setLocale(Locale(languageCode));
    setState(() {});
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url'.tr())),
      );
    }
  }

  Future<void> _resetAppSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Reset'.tr()),
        content: Text('This will reset all settings and data. Are you sure?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final finalConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Final Confirmation'.tr()),
          content: Text('This action cannot be undone. Proceed?'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Reset'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      );

      if (finalConfirmed == true) {
        await localStorageService.resetData();
        if (notificationService != null) {
          await notificationService!.cancelNotifications();
        }
        setState(() {
          _dailyNotifications = false;
          _fontSize = 16.0;
          _notificationTime = const TimeOfDay(hour: 9, minute: 0);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App settings reset successfully.'.tr())),
        );
      }
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LearnScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ToolsScreen()));
        break;
      case 4:
        break; // Already on SettingsScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final themeController = Provider.of<ThemeController>(context); // Assuming ThemeController is provided

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('⚙️ Settings'.tr()),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withOpacity(0.8) ?? Colors.transparent,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 1,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              height: 1.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: 8,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Display & Theme'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              case 1:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: SwitchListTile(
                    title: Text('Dark Mode'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                    value: themeController.isDarkMode,
                    onChanged: (value) {
                      themeController.toggleDarkMode(value);
                      localStorageService.saveSetting('darkMode', value);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: Icon(
                      themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              case 2:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: ListTile(
                    title: Text('Font Size'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      label: _fontSize.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                        localStorageService.saveSetting('fontSize', value);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    leading: Icon(Icons.format_size, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              case 3:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Notifications'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              case 4:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: SwitchListTile(
                    title: Text('Daily Notifications'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                    value: _dailyNotifications,
                    onChanged: _toggleNotifications,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: Icon(Icons.notifications, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              case 5:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: ListTile(
                    title: Text('Notification Time'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Text(_notificationTime.format(context)),
                    leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onTap: _dailyNotifications ? _selectNotificationTime : null,
                    enabled: _dailyNotifications,
                  ),
                );
              case 6:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'About'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              case 7:
                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('Select Language'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                        leading: Icon(Icons.language, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        trailing: DropdownButton<String>(
                          value: context.locale.languageCode,
                          items: [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'ar', child: Text('العربية')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _changeLanguage(value);
                            }
                          },
                          style: Theme.of(context).textTheme.bodyLarge,
                          underline: const SizedBox(),
                        ),
                      ),
                      ListTile(
                        title: Text('Refresh Content'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                        leading: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onTap: () async {
                          try {
                            await contentService!.syncContentFromGitHub();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Content refreshed!'.tr())),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error occurred. Please try again.'.tr())),
                            );
                          }
                        },
                      ),
                      ListTile(
                        title: Text('About App'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                        leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Digital Security App'.tr(),
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.security, size: 40),
                            children: [
                              Text('A tool to enhance your digital security knowledge and practices.'.tr()),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _launchURL('https://github.com/your_repo/easy_digital_security'),
                                child: Text('View on GitHub'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              ),
                            ],
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Privacy Policy'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                        leading: Icon(Icons.privacy_tip, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onTap: () => _launchURL('https://your_app.com/privacy.html'),
                      ),
                      ListTile(
                        title: Text('Reset App Settings'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                        leading: Icon(Icons.restore, color: Theme.of(context).colorScheme.error),
                        onTap: _resetAppSettings,
                      ),
                    ],
                  ),
                );
              default:
                return const SizedBox();
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: 'Learn'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.quiz),
              label: 'Quiz'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build),
              label: 'Tools'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'Settings'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}