import 'package:hive/hive.dart';
import '../models/tip_model.dart';
import '../models/quiz_model.dart';

class LocalStorageService {
  static const String settingsBoxName = 'settings';
  static const String tipsBoxName = 'tips';
  static const String quizzesBoxName = 'quizzes';
  static const String quizResultsBoxName = 'quiz_results';

  late Box _settingsBox;
  late Box<TipModel> _tipsBox;
  late Box<QuizModel> _quizzesBox;
  late Box<Map> _quizResultsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  Future<void> initTipsBox() async {
    _tipsBox = await Hive.openBox<TipModel>(tipsBoxName);
  }

  Future<void> initQuizzesBox() async {
    _quizzesBox = await Hive.openBox<QuizModel>(quizzesBoxName);
  }

  Future<void> initQuizResultsBox() async {
    _quizResultsBox = await Hive.openBox<Map>(quizResultsBoxName);
  }

  Future<void> addTips(List<TipModel> tips) async {
    await initTipsBox();
    await _tipsBox.clear();
    for (var tip in tips) {
      await _tipsBox.put(tip.id, tip);
    }
  }

  Future<void> addQuizzes(List<QuizModel> quizzes) async {
    await initQuizzesBox();
    await _quizzesBox.clear();
    for (var quiz in quizzes) {
      await _quizzesBox.put(quiz.id, quiz);
    }
  }

  Future<void> saveQuizResult(String quizId, int score, int totalQuestions) async {
    await initQuizResultsBox();
    await _quizResultsBox.put(quizId, {
      'score': score,
      'total_questions': totalQuestions,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  List<Map> getQuizResults() {
    return _quizResultsBox.values.toList().cast<Map>();
  }

  TipModel? getRandomTip() {
    if (_tipsBox.isEmpty) return null;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _tipsBox.length;
    return _tipsBox.values.elementAt(randomIndex);
  }

  List<TipModel> getAllTips() {
    return _tipsBox.values.toList();
  }

  List<QuizModel> getAllQuizzes() {
    return _quizzesBox.values.toList();
  }

  bool getOnboardingStatus() {
    return _settingsBox.get('onboardingCompleted', defaultValue: false);
  }

  Future<void> setOnboardingStatus(bool status) async {
    await _settingsBox.put('onboardingCompleted', status);
  }

  dynamic getSetting(String key, {required dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> resetData() async {
    await _settingsBox.clear();
    await _tipsBox.clear();
    await _quizzesBox.clear();
    await _quizResultsBox.clear();
  }
}