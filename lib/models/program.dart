
import 'package:hive/hive.dart';

part 'program.g.dart';

@HiveType(typeId: 6) // تأكد أن typeId فريد
class Program extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final int lesson; // عدد الدروس
  @HiveField(4)
  final String imagePath; // مسار الصورة

  Program({
    required this.id,
    required this.category,
    required this.name,
    required this.lesson,
    required this.imagePath,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      lesson: json['lesson'] as int,
      imagePath: json['imagePath'] as String,
    );
  }
}
