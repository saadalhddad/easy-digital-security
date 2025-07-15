import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/screens/home_screen.dart';
import 'package:easy_digital_security/screens/learn_screen.dart';
import 'package:easy_digital_security/screens/quiz_screen.dart';
import 'package:easy_digital_security/screens/settings_screen.dart';
import 'package:easy_digital_security/widgets/password_health_check.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  double _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';
  final TextEditingController _strengthCheckerController = TextEditingController();
  static const String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numberChars = '0123456789';
  static const String _symbolChars = '!@#\$%^&*()-_+=[]{}|;:,.<>?';
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  void dispose() {
    _strengthCheckerController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    String chars = _lowercaseChars;
    if (_includeUppercase) chars += _uppercaseChars;
    if (_includeNumbers) chars += _numberChars;
    if (_includeSymbols) chars += _symbolChars;

    if (chars.isEmpty) {
      setState(() {
        _generatedPassword = 'Select at least one character type'.tr();
      });
      return;
    }

    final random = Random.secure();
    String newPassword = '';
    for (int i = 0; i < _passwordLength; i++) {
      newPassword += chars[random.nextInt(chars.length)];
    }

    setState(() {
      _generatedPassword = newPassword;
    });
  }

  void _copyPasswordToClipboard() {
    if (_generatedPassword.isNotEmpty && _generatedPassword != 'Select at least one character type'.tr()) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password copied to clipboard!'.tr())),
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

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String description,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: Theme.of(context).cardTheme.color,
        surfaceTintColor: Theme.of(context).cardTheme.surfaceTintColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLocked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  isLocked ? Icons.lock : icon,
                  color: isLocked ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description.tr(),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock : Icons.arrow_forward,
                  color: isLocked ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🔧 Security Tools'.tr()),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildToolCard(
                icon: Icons.vpn_key,
                title: 'Create Strong Password',
                description: 'Generate secure, customizable passwords.',
                onTap: () {
                  // Scroll to Password Generator section
                  Scrollable.ensureVisible(
                    context,
                    alignment: 0.0,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  color: Theme.of(context).cardTheme.color,
                  surfaceTintColor: Theme.of(context).cardTheme.surfaceTintColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Generator'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Password Length: ${_passwordLength.toInt()}'.tr(args: [_passwordLength.toInt().toString()]),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          value: _passwordLength,
                          min: 8,
                          max: 32,
                          divisions: 24,
                          label: _passwordLength.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _passwordLength = value;
                              _generatePassword();
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                        SwitchListTile(
                          title: Text('Include Uppercase Letters'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                          value: _includeUppercase,
                          onChanged: (value) {
                            setState(() {
                              _includeUppercase = value;
                              _generatePassword();
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          secondary: Icon(Icons.abc, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        SwitchListTile(
                          title: Text('Include Numbers'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                          value: _includeNumbers,
                          onChanged: (value) {
                            setState(() {
                              _includeNumbers = value;
                              _generatePassword();
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          secondary: Icon(Icons.numbers, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        SwitchListTile(
                          title: Text('Include Symbols'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                          value: _includeSymbols,
                          onChanged: (value) {
                            setState(() {
                              _includeSymbols = value;
                              _generatePassword();
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          secondary: Icon(Icons.star_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _generatePassword,
                          icon: const Icon(Icons.refresh),
                          label: Text('Generate New Password'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: TextEditingController(text: _generatedPassword),
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyPasswordToClipboard,
                              tooltip: 'Copy'.tr(),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            labelText: 'Generated Password'.tr(),
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildToolCard(
                icon: Icons.shield,
                title: 'Analyze Password Strength',
                description: 'Check how strong your password is.',
                onTap: () {
                  // Scroll to Password Strength Checker section
                  Scrollable.ensureVisible(
                    context,
                    alignment: 0.0,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: PasswordStrengthChecker(),
              ),
              _buildToolCard(
                icon: Icons.email,
                title: 'Email Leak Checker',
                description: 'Check if your email has been compromised.',
                isLocked: true,
              ),
              _buildToolCard(
                icon: Icons.qr_code,
                title: '2FA Code Generator',
                description: 'Generate a mock 2FA code for testing.',
                isLocked: true,
              ),
              _buildToolCard(
                icon: Icons.link,
                title: 'Phishing Link Checker',
                description: 'Verify if a link is safe.',
                isLocked: true,
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