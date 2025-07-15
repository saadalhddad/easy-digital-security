import 'dart:convert';
import 'package:easy_digital_security/screens/learn_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/tip_model.dart';
import '../models/quiz_model.dart';
import '../models/article_model.dart';
import '../services/local_storage.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart' as helpers;

class ContentService {
  final LocalStorageService localStorageService;

  ContentService(this.localStorageService);

  Future<void> loadInitialContent() async {
    try {
      final tipsData = await compute(loadJsonAssetIsolate, AssetPaths.tipsJson);
      List<TipModel> tips;
      if (tipsData.isNotEmpty) {
        tips = tipsData.map((json) => TipModel.fromJson(json)).toList();
      } else {
        debugPrint('No tips found in ${AssetPaths.tipsJson}, loading default tips');
        tips = await getDefaultTips();
      }
      await localStorageService.addTips(tips);
      debugPrint('Tips loaded and stored in Hive: ${tips.length} tips');

      final quizzesData = await compute(loadJsonAssetIsolate, AssetPaths.quizzesJson);
      List<QuizModel> quizzes;
      if (quizzesData.isNotEmpty) {
        quizzes = quizzesData.map((json) => QuizModel.fromJson(json)).toList();
      } else {
        debugPrint('No quizzes found in ${AssetPaths.quizzesJson}, loading default quizzes');
        quizzes = await getDefaultQuizzes();
      }
      await localStorageService.addQuizzes(quizzes);
      debugPrint('Quizzes loaded and stored in Hive: ${quizzes.length} quizzes');

      final articlesData = await compute(loadJsonAssetIsolate, AssetPaths.articlesJson);
      List<Article> articles;
      if (articlesData.isNotEmpty) {
        articles = articlesData.map((json) => Article.fromJson(json)).toList();
      } else {
        debugPrint('No articles found in ${AssetPaths.articlesJson}, loading default articles');
        articles = await getDefaultArticles();
      }
      await localStorageService.addArticles(articles);
      debugPrint('Articles loaded and stored in Hive: ${articles.length} articles');
    } catch (e) {
      debugPrint('Error loading initial content: $e');
      throw Exception('Failed to load initial content: $e');
    }
  }

  Future<List<TipModel>> getDefaultTips() async {
    return [
      TipModel(
        id: 'default_tip1',
        titleEn: 'Use Strong Passwords',
        titleAr: 'استخدم كلمات مرور قوية',
        contentEn: 'Create passwords with at least 12 characters, including numbers, letters, and symbols.',
        contentAr: 'أنشئ كلمات مرور تحتوي على 12 حرفًا على الأقل، بما في ذلك أرقام وحروف ورموز.',
        imageUrl: '',
        category: 'Passwords',
      ),
      TipModel(
        id: 'default_tip2',
        titleEn: 'Enable Two-Factor Authentication',
        titleAr: 'تفعيل المصادقة الثنائية',
        contentEn: 'Add an extra layer of security with 2FA on all your accounts.',
        contentAr: 'أضف طبقة إضافية من الأمان بتفعيل المصادقة الثنائية على جميع حساباتك.',
        imageUrl: '',
        category: 'Authentication',
      ),
    ];
  }

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
            explanation: 'A strong password should be at least 12 characters long.',
            explanationAr: 'يجب أن تكون كلمة المرور القوية مكونة من 12 حرفًا على الأقل.',
          ),
        ],
      ),
    ];
  }

  Future<List<Article>> getDefaultArticles() async {
    return [
      Article(
        id: 'default_article1',
        fileName: 'password_security.md',
        titleEn: 'Password Security Basics',
        titleAr: 'أساسيات أمان كلمة المرور',
        category: 'Passwords',
      ),
      Article(
        id: 'default_article2',
        fileName: 'two_factor_authentication.md',
        titleEn: 'Understanding Two-Factor Authentication',
        titleAr: 'فهم المصادقة الثنائية',
        category: 'Authentication',
      ),
    ];
  }

  Future<List<TipModel>> getAllTips() async {
    try {
      return localStorageService.getAllTips();
    } catch (e) {
      debugPrint('Error retrieving tips: $e');
      throw Exception('Failed to retrieve tips: $e');
    }
  }

  Future<List<QuizModel>> getAllQuizzes() async {
    try {
      return localStorageService.getAllQuizzes();
    } catch (e) {
      debugPrint('Error retrieving quizzes: $e');
      throw Exception('Failed to retrieve quizzes: $e');
    }
  }

  Future<List<Article>> getAllArticles() async {
    try {
      return localStorageService.getAllArticles();
    } catch (e) {
      debugPrint('Error retrieving articles: $e');
      throw Exception('Failed to retrieve articles: $e');
    }
  }

  Future<String> getArticleContent(String fileName, String languageCode) async {
    try {
      final path = 'assets/content/articles/$languageCode/$fileName';
      final content = await helpers.CustomAssetLoader.getAsset(path);
      if (content == null || content.isEmpty) {
        debugPrint('Article $fileName not found for language $languageCode');
        throw Exception('Article content not found for $fileName');
      }
      return content;
    } catch (e) {
      debugPrint('Error loading article $fileName: $e');
      throw Exception('Failed to load article content: $e');
    }
  }

  Future<void> syncContentFromGitHub() async {
    try {
      // Sync tips
      final tipsResponse = await http.get(Uri.parse('${GitHubPaths.contentBaseUrl}/tips.json'));
      if (tipsResponse.statusCode == 200) {
        final tipsData = json.decode(tipsResponse.body) as List;
        if (tipsData.isNotEmpty) {
          final tips = tipsData.map((json) => TipModel.fromJson(json)).toList();
          await localStorageService.addTips(tips);
          debugPrint('Tips synced from GitHub: ${tips.length} tips');
        } else {
          debugPrint('No tips found in GitHub response');
        }
      } else {
        debugPrint('Failed to sync tips from GitHub: ${tipsResponse.statusCode}');
        throw Exception('Failed to sync tips: ${tipsResponse.statusCode}');
      }

      // Sync quizzes
      final quizzesResponse = await http.get(Uri.parse('${GitHubPaths.contentBaseUrl}/quizzes.json'));
      if (quizzesResponse.statusCode == 200) {
        final quizzesData = json.decode(quizzesResponse.body) as List;
        if (quizzesData.isNotEmpty) {
          final quizzes = quizzesData.map((json) => QuizModel.fromJson(json)).toList();
          await localStorageService.addQuizzes(quizzes);
          debugPrint('Quizzes synced from GitHub: ${quizzes.length} quizzes');
        } else {
          debugPrint('No quizzes found in GitHub response');
        }
      } else {
        debugPrint('Failed to sync quizzes from GitHub: ${quizzesResponse.statusCode}');
        throw Exception('Failed to sync quizzes: ${quizzesResponse.statusCode}');
      }

      // Sync articles
      final articlesResponse = await http.get(Uri.parse('${GitHubPaths.contentBaseUrl}/articles.json'));
      if (articlesResponse.statusCode == 200) {
        final articlesData = json.decode(articlesResponse.body) as List;
        if (articlesData.isNotEmpty) {
          final articles = articlesData.map((json) => Article.fromJson(json)).toList();
          await localStorageService.addArticles(articles);
          debugPrint('Articles synced from GitHub: ${articles.length} articles');
        } else {
          debugPrint('No articles found in GitHub response');
        }
      } else {
        debugPrint('Failed to sync articles from GitHub: ${articlesResponse.statusCode}');
        throw Exception('Failed to sync articles: ${articlesResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error syncing content from GitHub: $e');
      throw Exception('Failed to sync content from GitHub: $e');
    }
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
    throw Exception('Failed to load JSON asset: $e');
  }
}