import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/main.dart';
import 'package:easy_digital_security/models/tip_model.dart';
import 'package:easy_digital_security/screens/learn_screen.dart';
import 'package:easy_digital_security/screens/quiz_screen.dart';
import 'package:easy_digital_security/screens/tools_screen.dart';
import 'package:easy_digital_security/screens/settings_screen.dart';
import 'package:easy_digital_security/screens/tip_detail_screen.dart';
import 'package:easy_digital_security/widgets/tip_card.dart';
import 'package:easy_digital_security/widgets/progress_bar.dart';
import 'package:animate_do/animate_do.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  List<TipModel> _tips = [];
  int _currentIndex = 0;
  int _currentTipIndex = 0;
  Timer? _tipRotationTimer;

  @override
  void initState() {
    super.initState();
    _loadTips();
    _startTipRotation();
  }

  @override
  void dispose() {
    _tipRotationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTips() async {
    final tips = await localStorageService.getAllTips();
    setState(() {
      _tips = tips;
      _tips.shuffle();
    });
  }

  void _startTipRotation() {
    _tipRotationTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (_tips.isNotEmpty) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        // Optional: Play tip refresh sound (placeholder for audioplayers)
        // await audioPlayer.play(AssetSource('sounds/tip_refresh.mp3'));
      }
    });
  }

  void _loadNewTip() {
    setState(() {
      _tips.shuffle();
      _currentTipIndex = 0;
    });
    // Optional: Play tip refresh sound
    // await audioPlayer.play(AssetSource('sounds/tip_refresh.mp3'));
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        break; // Already on HomeScreen
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final filteredTips = _selectedCategory == 'All'
        ? _tips
        : _tips.where((tip) => tip.category == _selectedCategory).toList();
    final dailyTip = filteredTips.isNotEmpty ? filteredTips[_currentTipIndex % filteredTips.length] : null;

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🛡️ Digital Security Today'.tr()),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
              tooltip: 'Settings'.tr(),
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                setState(() {
                  _selectedCategory = result;
                  _currentTipIndex = 0;
                  _tips.shuffle();
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'All',
                  child: Text('All Categories'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Passwords',
                  child: Text('Passwords'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Phishing',
                  child: Text('Phishing'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Authentication',
                  child: Text('Authentication'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                PopupMenuItem<String>(
                  value: 'Privacy',
                  child: Text('Privacy'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
              icon: Icon(Icons.filter_list, color: Theme.of(context).appBarTheme.foregroundColor),
              tooltip: 'Filter Tips'.tr(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'Daily Security Tip'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: dailyTip == null
                    ? Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No tips available today. Check back later!'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : TipCard(
                  key: ValueKey(dailyTip.id), // Ensure animation on tip change
                  tip: dailyTip,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipDetailScreen(tip: dailyTip),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _loadNewTip,
                    icon: const Icon(Icons.refresh),
                    label: Text('New Tip'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'Your Progress'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ProgressBar(
                        progress: 0.25,
                        progressColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        height: 16,
                        label: '5 of 20 Tips Completed'.tr(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Icon(Icons.star, color: Colors.grey.shade300, size: 20),
                        const SizedBox(width: 6),
                        Icon(Icons.star, color: Colors.grey.shade300, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const QuizScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz),
                  label: Text('Start Quick Quiz'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LearnScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                        child: Text('Learn'.tr(), style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const ToolsScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                        child: Text('Tools'.tr(), style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                  ],
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