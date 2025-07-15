import 'package:easy_digital_security/models/lesson.dart';
import 'package:easy_digital_security/models/program.dart';
import 'package:easy_digital_security/utils/constants.dart'; // لاستخدام AssetPaths

// دالة وهمية لجلب بيانات الدروس
Future<List<Lesson>> getLessonInfo() async {
  await Future.delayed(const Duration(milliseconds: 500)); // محاكاة تأخير الشبكة
  return [
    Lesson(
      id: 'l1',
      category: 'Mindfulness',
      name: 'Understanding Emotions',
      duration: 30,
      imagePath: AssetPaths.imageYoga,
    ),
    Lesson(
      id: 'l2',
      category: 'Productivity',
      name: 'Time Management Basics',
      duration: 45,
      imagePath: AssetPaths.imageYoga,
    ),
    Lesson(
      id: 'l3',
      category: 'Health',
      name: 'Healthy Eating Habits',
      duration: 25,
      imagePath: AssetPaths.imageYoga,
    ),
  ];
}

// دالة وهمية لجلب بيانات البرامج
Future<List<Program>> getProgramInfo() async {
  await Future.delayed(const Duration(milliseconds: 500)); // محاكاة تأخير الشبكة
  return [
    Program(
      id: 'p1',
      category: 'LIFESTYLE',
      name: 'A complete guide for your new born baby',
      lesson: 16,
      imagePath: AssetPaths.imageFrame122,
    ),
    Program(
      id: 'p2',
      category: 'Working Parents',
      name: 'Understanding of human behaviour',
      lesson: 12,
      imagePath: AssetPaths.imageFrame123,
    ),
    Program(
      id: 'p3',
      category: 'Fitness',
      name: 'Daily Workout Routine',
      lesson: 8,
      imagePath: AssetPaths.imageFrame122,
    ),
  ];
}
