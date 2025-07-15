import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 5) // تأكد أن typeId فريد
class Lesson extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final int duration;
  @HiveField(4)
  final String imagePath; // مسار الصورة

  Lesson({
    required this.id,
    required this.category,
    required this.name,
    required this.duration,
    required this.imagePath,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      duration: json['duration'] as int,
      imagePath: json['imagePath'] as String,
    );
  }
}
