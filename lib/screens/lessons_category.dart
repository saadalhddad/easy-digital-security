import 'package:flutter/material.dart';
import 'package:easy_digital_security/models/lesson.dart'; // تم التعديل
import 'package:easy_digital_security/data/mock_data.dart'; // لاستيراد getLessonInfo
import 'package:easy_localization/easy_localization.dart'; // للترجمة
import 'package:easy_digital_security/utils/constants.dart'; // لاستخدام AssetPaths

class LessonsCategory extends StatefulWidget {
  const LessonsCategory({super.key});

  @override
  State<LessonsCategory> createState() => _LessonsCategoryState();
}

class _LessonsCategoryState extends State<LessonsCategory> {
  late Future<List<Lesson>> lessonData;

  @override
  void initState() {
    lessonData = getLessonInfo(); // استدعاء دالة جلب البيانات
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder<List<Lesson>>(
            future: lessonData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'.tr()); // رسالة خطأ مترجمة
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No lessons available.'.tr()); // رسالة مترجمة
              } else {
                return Expanded(
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final lesson = snapshot.data![index];
                        return LessonsItems(
                          title: lesson.category.tr(), // ترجمة الفئة
                          description: lesson.name.tr(), // ترجمة الاسم
                          duration: lesson.duration.toString(),
                          imagePath: AssetPaths.imageYoga, // استخدام مسار الصورة من Constants
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class LessonsItems extends StatelessWidget {
  const LessonsItems({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String duration;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    // الحصول على BorderRadius من الثيم بأمان
    final BorderRadius? cardBorderRadius = (Theme.of(context).cardTheme.shape is RoundedRectangleBorder)
        ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context))
        : null;

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 20, bottom: 20),
        width: 250, // يمكن جعلها أكثر استجابة
        height: 300,
        decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color, // استخدام لون البطاقة من الثيم
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
              )
            ],
            borderRadius: cardBorderRadius ?? BorderRadius.circular(15)), // استخدام حواف البطاقة من الثيم
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity, // لجعل الصورة تملأ العرض المتاح
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium,), // استخدام bodyMedium
                    Text(description, style: Theme.of(context).textTheme.bodyLarge,), // استخدام bodyLarge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$duration min', style: Theme.of(context).textTheme.labelLarge,), // استخدام labelLarge
                        Icon(Icons.lock_outline, color: Theme.of(context).textTheme.labelLarge?.color,) // استخدام لون الخط من الثيم
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
