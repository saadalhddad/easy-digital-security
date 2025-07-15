import 'dart:math';
import 'package:easy_digital_security/models/article_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../models/tip_model.dart';
import '../models/quiz_model.dart';

class LocalStorageService {
  static const String settingsBoxName = 'settings';
  static const String tipsBoxName = 'tips';
  static const String quizzesBoxName = 'quizzes';
  static const String quizResultsBoxName = 'quiz_results';
  static const String passwordResultsBoxName = 'password_results';

  late Box _settingsBox;
  late Box<TipModel> _tipsBox;
  late Box<QuizModel> _quizzesBox;
  late Box<Map> _quizResultsBox;
  late Box<Map> _passwordResultsBox;

  Future<void> init() async {
    try {
      _settingsBox = await Hive.openBox(settingsBoxName);
      _tipsBox = await Hive.openBox<TipModel>(tipsBoxName);
      _quizzesBox = await Hive.openBox<QuizModel>(quizzesBoxName);
      _quizResultsBox = await Hive.openBox<Map>(quizResultsBoxName);
      _passwordResultsBox = await Hive.openBox<Map>(passwordResultsBoxName);
      debugPrint('All Hive boxes initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive boxes: $e');
      throw Exception('Failed to initialize local storage: $e');
    }
  }

  Future<void> addTips(List<TipModel> tips) async {
    try {
      await _tipsBox.clear();
      for (var tip in tips) {
        await _tipsBox.put(tip.id, tip);
      }
      debugPrint('Stored ${tips.length} tips in Hive');
    } catch (e) {
      debugPrint('Error adding tips to Hive: $e');
      throw Exception('Failed to add tips: $e');
    }
  }

  Future<void> addQuizzes(List<QuizModel> quizzes) async {
    try {
      await _quizzesBox.clear();
      for (var quiz in quizzes) {
        await _quizzesBox.put(quiz.id, quiz);
      }
      debugPrint('Stored ${quizzes.length} quizzes in Hive');
    } catch (e) {
      debugPrint('Error adding quizzes to Hive: $e');
      throw Exception('Failed to add quizzes: $e');
    }
  }

  Future<void> saveQuizResult(String quizId, int score, int totalQuestions) async {
    try {
      await _quizResultsBox.put(quizId, {
        'score': score,
        'total_questions': totalQuestions,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('Saved quiz result for quizId: $quizId');
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
      throw Exception('Failed to save quiz result: $e');
    }
  }

  Future<void> savePasswordCheckResult(Map<String, dynamic> result) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _passwordResultsBox.put(timestamp, {
        'strength': result['strength'],
        'score': result['score'],
        'timestamp': timestamp,
      });
      debugPrint('Saved password check result at $timestamp');
    } catch (e) {
      debugPrint('Error saving password check result: $e');
      throw Exception('Failed to save password check result: $e');
    }
  }

  // Add to LocalStorageService in local_storage.dart
  static const String articlesBoxName = 'articles';
  late Box<Article> _articlesBox;

  Future<void> initArticlesBox() async {
    try {
      _articlesBox = await Hive.openBox<Article>(articlesBoxName);
      debugPrint('Articles box initialized');
    } catch (e) {
      debugPrint('Error initializing articles box: $e');
      throw Exception('Failed to initialize articles box: $e');
    }
  }

  Future<void> addArticles(List<Article> articles) async {
    try {
      await initArticlesBox();
      await _articlesBox.clear();
      for (var article in articles) {
        await _articlesBox.put(article.id, article);
      }
      debugPrint('Stored ${articles.length} articles in Hive');
    } catch (e) {
      debugPrint('Error adding articles to Hive: $e');
      throw Exception('Failed to add articles: $e');
    }
  }

  List<Article> getAllArticles() {
    try {
      return _articlesBox.values.toList();
    } catch (e) {
      debugPrint('Error retrieving articles: $e');
      return [];
    }
  }

  List<Map> getQuizResults() {
    try {
      return _quizResultsBox.values.toList().cast<Map>();
    } catch (e) {
      debugPrint('Error retrieving quiz results: $e');
      return [];
    }
  }

  List<Map> getPasswordCheckResults() {
    try {
      return _passwordResultsBox.values.toList().cast<Map>();
    } catch (e) {
      debugPrint('Error retrieving password check results: $e');
      return [];
    }
  }

  TipModel? getRandomTip() {
    try {
      if (_tipsBox.isEmpty) {
        debugPrint('No tips available in Hive');
        return null;
      }
      final random = Random();
      final randomIndex = random.nextInt(_tipsBox.length);
      return _tipsBox.values.elementAt(randomIndex);
    } catch (e) {
      debugPrint('Error getting random tip: $e');
      return null;
    }
  }

  List<TipModel> getAllTips() {
    try {
      return _tipsBox.values.toList();
    } catch (e) {
      debugPrint('Error retrieving all tips: $e');
      return [];
    }
  }

  List<QuizModel> getAllQuizzes() {
    try {
      return _quizzesBox.values.toList();
    } catch (e) {
      debugPrint('Error retrieving all quizzes: $e');
      return [];
    }
  }

  bool getOnboardingStatus() {
    try {
      return _settingsBox.get('onboardingCompleted', defaultValue: false);
    } catch (e) {
      debugPrint('Error retrieving onboarding status: $e');
      return false;
    }
  }

  Future<void> setOnboardingStatus(bool status) async {
    try {
      await _settingsBox.put('onboardingCompleted', status);
      debugPrint('Set onboarding status to $status');
    } catch (e) {
      debugPrint('Error setting onboarding status: $e');
      throw Exception('Failed to set onboarding status: $e');
    }
  }

  dynamic getSetting(String key, {required dynamic defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      debugPrint('Error retrieving setting $key: $e');
      return defaultValue;
    }
  }

  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
      debugPrint('Saved setting $key: $value');
    } catch (e) {
      debugPrint('Error saving setting $key: $e');
      throw Exception('Failed to save setting: $e');
    }
  }

  Future<void> resetData() async {
    try {
      await _settingsBox.clear();
      await _tipsBox.clear();
      await _quizzesBox.clear();
      await _quizResultsBox.clear();
      await _passwordResultsBox.clear();
      debugPrint('All local storage data reset');
    } catch (e) {
      debugPrint('Error resetting local storage: $e');
      throw Exception('Failed to reset local storage: $e');
    }
  }
}