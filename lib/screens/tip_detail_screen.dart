import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/models/tip_model.dart'; // استيراد TipModel

class TipDetailScreen extends StatelessWidget {
  final TipModel tip; // النصيحة التي سيتم عرض تفاصيلها

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final title = isArabic ? tip.titleAr : tip.titleEn;
    final content = isArabic ? tip.contentAr : tip.contentEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض الصورة في الأعلى
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                tip.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade600),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // عنوان النصيحة
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // محتوى النصيحة
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
