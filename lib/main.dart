import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_digital_security/models/tip_model.dart';
import 'package:easy_digital_security/models/quiz_model.dart';
import 'package:easy_digital_security/services/content_service.dart';
import 'package:easy_digital_security/services/local_storage.dart';
import 'package:easy_digital_security/services/notification_service.dart';
import 'package:easy_digital_security/screens/home_screen.dart';
import 'package:easy_digital_security/screens/onboarding_screen.dart';

ContentService? contentService;
LocalStorageService localStorageService = LocalStorageService();
NotificationService? notificationService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TipModelAdapter());
  Hive.registerAdapter(QuizModelAdapter());
  Hive.registerAdapter(QuestionModelAdapter());
  Hive.registerAdapter(AnswerModelAdapter());

  await localStorageService.init();
  contentService = ContentService(localStorageService);
  notificationService = NotificationService(localStorageService);
  await notificationService!.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/localization',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: FutureBuilder<bool>(
        future: Future.value(localStorageService.getOnboardingStatus()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            contentService!.loadInitialContent();
          });
          return snapshot.data == true ? const HomeScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}