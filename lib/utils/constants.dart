import 'package:flutter/material.dart';

class HiveBoxNames {
  static const String tipsBox = 'tipsBox';
  static const String quizResultsBox = 'quizResultsBox';
  static const String userSettingsBox = 'userSettingsBox';
  static const String quizzesBox = 'quizzesBox';
  static const String favoriteArticlesBox = 'favoriteArticlesBox';
}

class HiveKeys {
  static const String userSettings = 'userSettings';
}

class AssetPaths {
  static const String localization = 'assets/localization';
  static const String tipsJson = 'assets/content/tips.json';
  static const String quizzesJson = 'assets/content/quizzes.json';
  static const String articles = 'assets/content/articles/';
  static const String articlesJson = 'assets/content/articles.json';
  static const String imageYoga = 'assets/images/young-woman-doing-natarajasana-exercise 1.jpg';
  static const String imageFrame122 = 'assets/images/Frame 122.jpg';
  static const String imageFrame123 = 'assets/images/Frame 123.jpg';
  static const String tipImageStrongPasswords = 'https://placehold.co/600x400/ADD8E6/000000?text=Strong+Passwords';
  static const String tipImageTwoFactorAuth = 'https://placehold.co/600x400/90EE90/000000?text=Two-Factor+Auth';
  static const String tipImagePhishingWarning = 'https://placehold.co/600x400/FFB6C1/000000?text=Phishing+Warning';
  static const String tipImageSoftwareUpdate = 'https://placehold.co/600x400/DDA0DD/000000?text=Software+Update';
}

class AppThemes {
  static const Color _secureBlue = Color(0xFF1E88E5);
  static const Color _warningRed = Color(0xFFD32F2F);
  static const Color _oldGrey = Color(0xFF6D747A);
  static const Color _oldBlack = Colors.black;
  static const Color _oldWhite = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _secureBlue,
      primary: _secureBlue,
      onPrimary: _oldWhite,
      secondary: _secureBlue,
      onSecondary: _oldWhite,
      surface: _oldWhite,
      onSurface: _oldBlack,
      background: _oldWhite,
      onBackground: _oldBlack,
      error: _warningRed,
      onError: _oldWhite,
      surfaceVariant: Colors.grey.shade100,
      onSurfaceVariant: _oldGrey,
      outline: _secureBlue,
    ),
    scaffoldBackgroundColor: _oldWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: _oldWhite,
      foregroundColor: _oldGrey,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _oldBlack,
        fontFamily: 'Lora',
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: _oldWhite,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 3,
        backgroundColor: _secureBlue,
        foregroundColor: _oldWhite,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _secureBlue, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        foregroundColor: _secureBlue,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _oldGrey,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(color: _oldBlack, fontFamily: 'Lora', fontWeight: FontWeight.w500, fontSize: 18),
      displayMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _oldGrey),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _oldBlack),
      bodyMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _secureBlue),
      labelLarge: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _oldGrey),
      headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _oldBlack),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _oldBlack),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _oldBlack),
      bodySmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _oldGrey),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _secureBlue,
      foregroundColor: _oldWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _secureBlue,
      unselectedItemColor: _oldGrey,
      backgroundColor: _oldWhite,
      elevation: 0,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _secureBlue,
      primary: _secureBlue,
      onPrimary: _oldWhite,
      secondary: _secureBlue,
      onSecondary: _oldWhite,
      surface: Colors.grey.shade800,
      onSurface: _oldWhite,
      background: Colors.grey.shade900,
      onBackground: _oldWhite,
      error: _warningRed,
      onError: _oldBlack,
      surfaceVariant: Colors.grey.shade700,
      onSurfaceVariant: Colors.grey.shade300,
      outline: _secureBlue,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.grey.shade300,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _oldWhite,
        fontFamily: 'Lora',
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey.shade800,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 3,
        backgroundColor: _secureBlue,
        foregroundColor: _oldWhite,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _secureBlue, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        foregroundColor: _secureBlue,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade400,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: _oldWhite, fontFamily: 'Lora', fontWeight: FontWeight.w500, fontSize: 18),
      displayMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _oldWhite),
      bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _secureBlue),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
      headlineSmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _oldWhite),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _oldWhite),
      bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _secureBlue,
      foregroundColor: _oldWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _secureBlue,
      unselectedItemColor: Colors.grey.shade400,
      backgroundColor: Colors.grey.shade800,
      elevation: 0,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
  );
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
