import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import '../models/tip_model.dart';
import '../models/quiz_model.dart';
import '../services/local_storage.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart' as helpers;
import 'package:easy_localization/easy_localization.dart';

class ContentService {
  final LocalStorageService localStorageService;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  ContentService(this.localStorageService);

  /// Loads initial content (tips and quizzes) from assets or local storage, falling back to defaults if needed.
  Future<void> loadInitialContent() async {
    try {
      // Load tips
      final tipsData = await compute(loadJsonAssetIsolate, AssetPaths.tipsJson);
      List<TipModel> tips;
      if (tipsData.isNotEmpty && _validateTips(tipsData)) {
        tips = tipsData.map((json) => TipModel.fromJson(json)).toList();
      } else {
        debugPrint('No valid tips found in ${AssetPaths.tipsJson}, loading default tips');
        tips = await getDefaultTips();
      }
      await localStorageService.addTips(tips);
      debugPrint('Tips loaded and stored in Hive: ${tips.length} tips');

      // Load quizzes
      final quizzesData = await compute(loadJsonAssetIsolate, AssetPaths.quizzesJson);
      List<QuizModel> quizzes;
      if (quizzesData.isNotEmpty && _validateQuizzes(quizzesData)) {
        quizzes = quizzesData.map((json) => QuizModel.fromJson(json)).toList();
      } else {
        debugPrint('No valid quizzes found in ${AssetPaths.quizzesJson}, loading default quizzes');
        quizzes = await getDefaultQuizzes();
      }
      await localStorageService.addQuizzes(quizzes);
      debugPrint('Quizzes loaded and stored in Hive: ${quizzes.length} quizzes');

      // Log content load success for analytics
      _logEvent('content_load_success', {'tips_count': tips.length, 'quizzes_count': quizzes.length});
    } catch (e) {
      debugPrint('Error loading initial content: $e');
      _logEvent('content_load_failure', {'error': e.toString()});
      // Notify user of failure (can be shown in UI)
      throw Exception('Failed to load initial content: $e'.tr());
    }
  }

  /// Validates tip data to ensure required fields are present.
  bool _validateTips(List<dynamic> tipsData) {
    return tipsData.every((json) =>
    json['id'] != null &&
        json['titleEn'] != null &&
        json['titleAr'] != null &&
        json['contentEn'] != null &&
        json['contentAr'] != null &&
        json['category'] != null);
  }

  /// Validates quiz data to ensure required fields are present.
  bool _validateQuizzes(List<dynamic> quizzesData) {
    return quizzesData.every((json) =>
    json['id'] != null &&
        json['titleEn'] != null &&
        json['titleAr'] != null &&
        json['questions'] != null &&
        (json['questions'] as List).every((q) =>
        q['id'] != null &&
            q['questionEn'] != null &&
            q['questionAr'] != null &&
            q['correctAnswerId'] != null &&
            q['answers'] != null &&
            (q['answers'] as List).every((a) => a['id'] != null && a['textEn'] != null && a['textAr'] != null)));
  }

  /// Provides default tips if asset or network loading fails.
  Future<List<TipModel>> getDefaultTips() async {
    return [
      TipModel(
        id: 'default_tip1',
        titleEn: 'Use Strong Passwords',
        titleAr: 'استخدم كلمات مرور قوية',
        contentEn: 'Create passwords with at least 12 characters, including letters, numbers, and symbols.',
        contentAr: 'أنشئ كلمات مرور تحتوي على 12 حرفًا على الأقل، تتضمن حروفًا وأرقامًا ورموزًا.',
        imageUrl: '',
        category: 'Passwords',
      ),
      TipModel(
        id: 'default_tip2',
        titleEn: 'Enable Two-Factor Authentication',
        titleAr: 'تفعيل المصادقة الثنائية',
        contentEn: 'Add an extra layer of security with 2FA to protect your accounts.',
        contentAr: 'أضف طبقة إضافية من الأمان بتفعيل المصادقة الثنائية لحماية حساباتك.',
        imageUrl: '',
        category: 'Authentication',
      ),
    ];
  }

  /// Provides default quizzes if asset or network loading fails.
  Future<List<QuizModel>> getDefaultQuizzes() async {
    return [
      QuizModel(
        id: 'default_quiz1',
        titleEn: 'Password Security Quiz',
        titleAr: 'اختبار أمان كلمة المرور',
        questions: [
          QuestionModel(
            id: 'q1',
            questionEn: 'What is the minimum recommended length for a strong password?',
            questionAr: 'ما هو الحد الأدنى الموصى به لطول كلمة المرور القوية؟',
            answers: [
              AnswerModel(id: 'a1', textEn: '6 characters', textAr: '6 أحرف', isCorrect: false),
              AnswerModel(id: 'a2', textEn: '12 characters', textAr: '12 حرفًا', isCorrect: true),
              AnswerModel(id: 'a3', textEn: '8 characters', textAr: '8 أحرف', isCorrect: false),
              AnswerModel(id: 'a4', textEn: '10 characters', textAr: '10 أحرف', isCorrect: false),
            ],
            correctAnswerId: 'a2',
            explanation: 'A strong password should be at least 12 characters long to resist brute-force attacks.',
            explanationAr: 'يجب أن تكون كلمة المرور القوية مكونة من 12 حرفًا على الأقل لمقاومة هجمات القوة الغاشمة.',
          ),
        ],
      ),
    ];
  }

  /// Retrieves all quizzes from local storage, initializing the box if needed.
  Future<List<QuizModel>> getAllQuizzes() async {
    try {
      await localStorageService.initQuizzesBox();
      final quizzes = localStorageService.getAllQuizzes();
      if (quizzes.isEmpty) {
        debugPrint('No quizzes in local storage, loading defaults');
        final defaultQuizzes = await getDefaultQuizzes();
        await localStorageService.addQuizzes(defaultQuizzes);
        return defaultQuizzes;
      }
      return quizzes;
    } catch (e) {
      debugPrint('Error retrieving quizzes: $e');
      _logEvent('quiz_retrieval_failure', {'error': e.toString()});
      throw Exception('Failed to retrieve quizzes: $e'.tr());
    }
  }

  /// Retrieves all tips from local storage, initializing the box if needed.
  Future<List<TipModel>> getAllTips() async {
    try {
      await localStorageService.initTipsBox();
      final tips = localStorageService.getAllTips();
      if (tips.isEmpty) {
        debugPrint('No tips in local storage, loading defaults');
        final defaultTips = await getDefaultTips();
        await localStorageService.addTips(defaultTips);
        return defaultTips;
      }
      return tips;
    } catch (e) {
      debugPrint('Error retrieving tips: $e');
      _logEvent('tip_retrieval_failure', {'error': e.toString()});
      throw Exception('Failed to retrieve tips: $e'.tr());
    }
  }

  /// Loads article content from assets or local storage.
  Future<String> getArticleContent(String fileName, String languageCode) async {
    try {
      final path = 'assets/content/articles/$languageCode/$fileName';
      final content = await helpers.CustomAssetLoader.getAsset(path);
      if (content == null || content.isEmpty) {
        debugPrint('Article $fileName not found for language $languageCode');
        return '';
      }
      return content;
    } catch (e) {
      debugPrint('Error loading article $fileName: $e');
      _logEvent('article_load_failure', {'fileName': fileName, 'error': e.toString()});
      return '';
    }
  }

  /// Syncs content from GitHub with retry mechanism and falls back to local storage.
  Future<void> syncContentFromGitHub() async {
    const retryOptions = RetryOptions(
      maxAttempts: _maxRetries,
      delayFactor: _retryDelay,
      randomizationFactor: 0.5,
    );

    try {
      // Sync tips
      final tipsResponse = await retryOptions.retry(
            () => http.get(Uri.parse(
            'https://github.com/saadalhddad/easy-digital-security.git/main/assets/content/tips.json')),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
      );
      if (tipsResponse.statusCode == 200) {
        final tipsData = json.decode(tipsResponse.body) as List;
        if (tipsData.isNotEmpty && _validateTips(tipsData)) {
          final tips = tipsData.map((json) => TipModel.fromJson(json)).toList();
          await localStorageService.addTips(tips);
          debugPrint('Tips synced from GitHub: ${tips.length} tips');
          _logEvent('tips_sync_success', {'count': tips.length});
        } else {
          debugPrint('No valid tips found in GitHub response');
          _logEvent('tips_sync_empty', {});
        }
      } else {
        debugPrint('Failed to sync tips from GitHub: ${tipsResponse.statusCode}');
        _logEvent('tips_sync_failure', {'statusCode': tipsResponse.statusCode});
      }

      // Sync quizzes
      final quizzesResponse = await retryOptions.retry(
            () => http.get(Uri.parse(
            'https://github.com/saadalhddad/easy-digital-security.git/main/assets/content/quizzes.json')),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
      );
      if (quizzesResponse.statusCode == 200) {
        final quizzesData = json.decode(quizzesResponse.body) as List;
        if (quizzesData.isNotEmpty && _validateQuizzes(quizzesData)) {
          final quizzes = quizzesData.map((json) => QuizModel.fromJson(json)).toList();
          await localStorageService.addQuizzes(quizzes);
          debugPrint('Quizzes synced from GitHub: ${quizzes.length} quizzes');
          _logEvent('quizzes_sync_success', {'count': quizzes.length});
        } else {
          debugPrint('No valid quizzes found in GitHub response');
          _logEvent('quizzes_sync_empty', {});
        }
      } else {
        debugPrint('Failed to sync quizzes from GitHub: ${quizzesResponse.statusCode}');
        _logEvent('quizzes_sync_failure', {'statusCode': quizzesResponse.statusCode});
      }

      // Sync articles
      final articlesResponse = await retryOptions.retry(
            () => http.get(Uri.parse(
            'https://raw.githubusercontent.com/your_repo/easy_digital_security/main/assets/content/articles.json')),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
      );
      if (articlesResponse.statusCode == 200) {
        final articlesData = json.decode(articlesResponse.body) as List;
        if (articlesData.isNotEmpty) {
          debugPrint('Articles synced from GitHub: ${articlesData.length} articles');
          _logEvent('articles_sync_success', {'count': articlesData.length});
          // Process articles (e.g., save to local storage or cache)
          // await localStorageService.addArticles(articlesData); // Placeholder for article storage
        } else {
          debugPrint('No articles found in GitHub response');
          _logEvent('articles_sync_empty', {});
        }
      } else {
        debugPrint('Failed to sync articles from GitHub: ${articlesResponse.statusCode}');
        _logEvent('articles_sync_failure', {'statusCode': articlesResponse.statusCode});
      }
    } catch (e) {
      debugPrint('Error syncing content from GitHub: $e');
      _logEvent('content_sync_failure', {'error': e.toString()});
      throw Exception('Failed to sync content: $e'.tr());
    }
  }

  /// Logs events for debugging and analytics (placeholder for future telemetry integration).
  void _logEvent(String eventName, Map<String, dynamic> properties) {
    debugPrint('Event: $eventName, Properties: $properties');
    // Placeholder for analytics service (e.g., Firebase Analytics)
    // analyticsService.logEvent(eventName, properties);
  }
}

Future<List<dynamic>> loadJsonAssetIsolate(String path) async {
  try {
    final jsonString = await helpers.CustomAssetLoader.getAsset(path);
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('Asset $path is empty or not found');
      return [];
    }
    return json.decode(jsonString) as List<dynamic>;
  } catch (e) {
    debugPrint('Error loading JSON from $path: $e');
    return [];
  }
}