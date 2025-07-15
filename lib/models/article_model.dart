import 'package:hive/hive.dart';

part 'article_model.g.dart';

@HiveType(typeId: 3)
class Article {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fileName;

  @HiveField(2)
  final String titleEn;

  @HiveField(3)
  final String titleAr;

  @HiveField(4)
  final String category;

  Article({
    required this.id,
    required this.fileName,
    required this.titleEn,
    required this.titleAr,
    required this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      fileName: json['file_name'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      category: json['category'] ?? 'All',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'title_en': titleEn,
      'title_ar': titleAr,
      'category': category,
    };
  }
}