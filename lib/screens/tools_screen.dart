import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/main.dart';
import 'package:easy_digital_security/screens/home_screen.dart';
import 'package:easy_digital_security/screens/learn_screen.dart';
import 'package:easy_digital_security/screens/quiz_screen.dart';
import 'package:easy_digital_security/screens/settings_screen.dart';
import 'package:easy_digital_security/widgets/password_health_check.dart';
import 'package:animate_do/animate_do.dart';

class Tool {
  final String titleEn;
  final String titleAr;
  final IconData icon;
  final bool isLocked;
  final VoidCallback? onTap;

  Tool({
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    this.isLocked = false,
    this.onTap,
  });
}

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int _currentIndex = 3;
  final List<Tool> _tools = [
    Tool(
      titleEn: 'Password Strength Checker',
      titleAr: 'فحص قوة كلمة المرور',
      icon: Icons.lock_outline,
      isLocked: false,
      onTap: null, // Handled in build method
    ),
    Tool(
      titleEn: 'Email Leak Checker',
      titleAr: 'فحص تسرب البريد الإلكتروني',
      icon: Icons.email_outlined,
      isLocked: true,
    ),
    Tool(
      titleEn: '2FA Code Generator',
      titleAr: 'مولد رمز التوثيق الثنائي',
      icon: Icons.security,
      isLocked: true,
    ),
    Tool(
      titleEn: 'Phishing Link Checker',
      titleAr: 'فحص روابط التصيد',
      icon: Icons.link_off,
      isLocked: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTools();
  }

  Future<void> _initializeTools() async {
    try {
      await contentService!.syncContentFromGitHub();
      // Optionally preload tips related to password strength
      final tips = await contentService!.getAllTips();
      final passwordTips = tips.where((tip) => tip.category == 'Passwords').toList();
      if (passwordTips.isNotEmpty && notificationService != null) {
        final tip = passwordTips.first;
        await notificationService!.scheduleDailyTipNotification(
          context, // تمرير BuildContext
          context.locale.languageCode == 'ar' ? tip.titleAr : tip.titleEn,
          context.locale.languageCode == 'ar' ? tip.contentAr : tip.contentEn,
        );
      }
    } catch (e) {
      debugPrint('Error initializing tools or scheduling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing tools: $e'.tr())),
      );
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
        break; // Already on ToolsScreen
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🛠️ Security Tools'.tr()),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withOpacity(0.8) ?? Colors.transparent,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'Explore Tools'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _tools.length,
                  itemBuilder: (context, index) {
                    final tool = _tools[index];
                    final title = isArabic ? tool.titleAr : tool.titleEn;
                    return FadeInUp(
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(
                            tool.icon,
                            color: tool.isLocked
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: tool.isLocked
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          trailing: tool.isLocked
                              ? Icon(Icons.lock, color: Theme.of(context).colorScheme.error)
                              : const Icon(Icons.arrow_forward_ios),
                          onTap: tool.isLocked
                              ? null
                              : () {
                            if (tool.titleEn == 'Password Strength Checker') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PasswordStrengthChecker(
                                    onCheck: (result) async {
                                      try {
                                        await localStorageService.savePasswordCheckResult(result);
                                        if (notificationService != null) {
                                          await notificationService!.schedulePasswordCheckNotification(
                                            context, // تمرير BuildContext
                                            result['strength'] ?? 'Unknown',
                                          );
                                        }
                                      } catch (e) {
                                        debugPrint('Error saving or notifying password check result: $e');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error saving password check result: $e'.tr())),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            } else if (tool.onTap != null) {
                              tool.onTap!();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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