import 'package:hive/hive.dart';
part 'tip_model.g.dart';

@HiveType(typeId: 0)
class TipModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titleEn;

  @HiveField(2)
  final String titleAr;

  @HiveField(3)
  final String contentEn;

  @HiveField(4)
  final String contentAr;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final String category;

  TipModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.contentEn,
    required this.contentAr,
    required this.imageUrl,
    required this.category,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      contentEn: json['content_en'] ?? '',
      contentAr: json['content_ar'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'All',
    );
  }
}