import 'package:hive/hive.dart';
part 'quiz_model.g.dart';

@HiveType(typeId: 1)
class QuizModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titleEn;

  @HiveField(2)
  final String titleAr;

  @HiveField(3)
  final List<QuestionModel> questions;

  QuizModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    var questionsJson = json['questions'] as List? ?? [];
    return QuizModel(
      id: json['id'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      questions: questionsJson.map((q) => QuestionModel.fromJson(q)).toList(),
    );
  }
}

@HiveType(typeId: 2)
class QuestionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String questionEn;

  @HiveField(2)
  final String questionAr;

  @HiveField(3)
  final List<AnswerModel> answers;

  @HiveField(4)
  final String correctAnswerId;

  @HiveField(5)
  final String explanation;

  @HiveField(6)
  final String explanationAr;

  QuestionModel({
    required this.id,
    required this.questionEn,
    required this.questionAr,
    required this.answers,
    required this.correctAnswerId,
    required this.explanation,
    required this.explanationAr,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var answersJson = json['answers'] as List? ?? [];
    return QuestionModel(
      id: json['id'] ?? '',
      questionEn: json['text_en'] ?? '',
      questionAr: json['text_ar'] ?? '',
      answers: answersJson.map((a) => AnswerModel.fromJson(a)).toList(),
      correctAnswerId: json['correct_answer_id'] ?? '',
      explanation: json['explanation'] ?? '',
      explanationAr: json['explanation_ar'] ?? '',
    );
  }
}

@HiveType(typeId: 3)
class AnswerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String textEn;

  @HiveField(2)
  final String textAr;

  @HiveField(3)
  final bool isCorrect;

  AnswerModel({
    required this.id,
    required this.textEn,
    required this.textAr,
    required this.isCorrect,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] ?? '',
      textEn: json['text_en'] ?? '',
      textAr: json['text_ar'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}