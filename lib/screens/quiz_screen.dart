import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/models/quiz_model.dart';
import 'package:easy_digital_security/services/content_service.dart';
import 'package:easy_digital_security/main.dart';
import 'package:easy_digital_security/screens/home_screen.dart';
import 'package:easy_digital_security/screens/learn_screen.dart';
import 'package:easy_digital_security/screens/tools_screen.dart';
import 'package:easy_digital_security/screens/settings_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizModel> _quizzes = [];
  QuizModel? _currentQuiz;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _quizStarted = false;
  bool _quizCompleted = false;
  bool _showAnswerFeedback = false;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    _quizzes = await contentService!.getAllQuizzes();
    if (_quizzes.isNotEmpty) {
      setState(() {
        _currentQuiz = _quizzes.first;
      });
    } else {
      debugPrint('No quizzes loaded.');
    }
  }

  void _startQuiz() {
    if (_currentQuiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No quiz available to start.'.tr())),
      );
      return;
    }
    setState(() {
      _quizStarted = true;
      _quizCompleted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _showAnswerFeedback = false;
    });
    // Optional: Play start quiz sound (placeholder for audioplayers)
    // await audioPlayer.play(AssetSource('sounds/quiz_start.mp3'));
  }

  void _checkAnswer() {
    if (_selectedAnswerIndex != null) {
      setState(() {
        _showAnswerFeedback = true;
        if (_currentQuiz!.questions[_currentQuestionIndex].answers[_selectedAnswerIndex!].id ==
            _currentQuiz!.questions[_currentQuestionIndex].correctAnswerId) {
          _score++;
          // Optional: Play correct answer sound
          // await audioPlayer.play(AssetSource('sounds/correct.mp3'));
        } else {
          // Optional: Play incorrect answer sound
          // await audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an answer.'.tr())),
      );
    }
  }

  void _nextQuestion() {
    setState(() {
      _showAnswerFeedback = false;
      _selectedAnswerIndex = null;
      if (_currentQuestionIndex < _currentQuiz!.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _quizCompleted = true;
        localStorageService.saveQuizResult(
          _currentQuiz!.id,
          _score,
          _currentQuiz!.questions.length,
        );
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _quizStarted = false;
      _quizCompleted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _showAnswerFeedback = false;
    });
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
        break; // Already on QuizScreen
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
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🧠 Security Quiz'.tr()),
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _currentQuiz == null
            ? Center(child: Text('Loading quizzes...'.tr(), style: Theme.of(context).textTheme.bodyLarge))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_quizStarted) ...[
                const Spacer(),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Icon(Icons.quiz, size: 60, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Ready to challenge your knowledge?'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'This quiz has {length} questions.'.tr(args: [_currentQuiz!.questions.length.toString()]),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: ElevatedButton.icon(
                    onPressed: _startQuiz,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Start Quiz'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const Spacer(),
              ] else if (_quizCompleted) ...[
                const Spacer(),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: CircularPercentIndicator(
                    radius: 70.0,
                    lineWidth: 10.0,
                    percent: _score / _currentQuiz!.questions.length,
                    center: Text(
                      '$_score/${_currentQuiz!.questions.length}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    progressColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Quiz Completed!'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'You scored {score} out of {total} questions.'.tr(args: [_score.toString(), _currentQuiz!.questions.length.toString()]),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    _score / _currentQuiz!.questions.length >= 0.7 ? 'Great job! Keep learning!'.tr() : 'Nice try! Review and try again!'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: ElevatedButton.icon(
                    onPressed: _restartQuiz,
                    icon: const Icon(Icons.refresh),
                    label: Text('Restart Quiz'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                    icon: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Back to Home'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const Spacer(),
              ] else ...[
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _currentQuiz!.questions.length,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Question {current} of {total}'.tr(args: [(_currentQuestionIndex + 1).toString(), _currentQuiz!.questions.length.toString()]),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Theme.of(context).cardTheme.color,
                          surfaceTintColor: Theme.of(context).cardTheme.surfaceTintColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              isArabic ? _currentQuiz!.questions[_currentQuestionIndex].questionAr : _currentQuiz!.questions[_currentQuestionIndex].questionEn,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: _currentQuiz!.questions[_currentQuestionIndex].answers.asMap().entries.map((entry) {
                              int idx = entry.key;
                              AnswerModel answer = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: FadeInUp(
                                  duration: Duration(milliseconds: 800 + (idx * 100)),
                                  child: GestureDetector(
                                    onTap: _showAnswerFeedback
                                        ? null
                                        : () {
                                      setState(() {
                                        _selectedAnswerIndex = idx;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _showAnswerFeedback
                                            ? (answer.id == _currentQuiz!.questions[_currentQuestionIndex].correctAnswerId
                                            ? Colors.green.shade100
                                            : (_selectedAnswerIndex == idx ? Colors.red.shade100 : Theme.of(context).colorScheme.surfaceVariant))
                                            : (_selectedAnswerIndex == idx
                                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                            : Theme.of(context).colorScheme.surfaceVariant),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _selectedAnswerIndex == idx
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).shadowColor.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                            value: idx,
                                            groupValue: _selectedAnswerIndex,
                                            onChanged: _showAnswerFeedback
                                                ? null
                                                : (value) {
                                              setState(() {
                                                _selectedAnswerIndex = value;
                                              });
                                            },
                                            activeColor: Theme.of(context).colorScheme.primary,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          Expanded(
                                            child: Text(
                                              isArabic ? answer.textAr : answer.textEn,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: _showAnswerFeedback
                                                    ? (answer.id == _currentQuiz!.questions[_currentQuestionIndex].correctAnswerId
                                                    ? Colors.green.shade900
                                                    : (_selectedAnswerIndex == idx ? Colors.red.shade900 : Theme.of(context).colorScheme.onSurface))
                                                    : Theme.of(context).colorScheme.onSurface,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                          if (_showAnswerFeedback)
                                            Icon(
                                              answer.id == _currentQuiz!.questions[_currentQuestionIndex].correctAnswerId
                                                  ? Icons.check_circle
                                                  : (_selectedAnswerIndex == idx ? Icons.cancel : null),
                                              color: answer.id == _currentQuiz!.questions[_currentQuestionIndex].correctAnswerId
                                                  ? Colors.green.shade900
                                                  : Colors.red.shade900,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: ElevatedButton(
                    onPressed: _selectedAnswerIndex == null && !_showAnswerFeedback
                        ? null
                        : (_showAnswerFeedback ? _nextQuestion : _checkAnswer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedAnswerIndex == null && !_showAnswerFeedback
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 2,
                    ),
                    child: Text(
                      _showAnswerFeedback
                          ? (_currentQuestionIndex == _currentQuiz!.questions.length - 1 ? 'Finish Quiz'.tr() : 'Next Question'.tr())
                          : 'Check Answer'.tr(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
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