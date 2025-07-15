import 'package:flutter/material.dart';
import 'package:easy_digital_security/models/program.dart'; // تم التعديل
import 'package:easy_digital_security/data/mock_data.dart'; // لاستيراد getProgramInfo
import 'package:easy_localization/easy_localization.dart'; // للترجمة
import 'package:easy_digital_security/utils/constants.dart'; // لاستخدام AssetPaths

class CategoryPrograms extends StatefulWidget {
  const CategoryPrograms({super.key});

  @override
  State<CategoryPrograms> createState() => _CategoryProgramsState();
}

class _CategoryProgramsState extends State<CategoryPrograms> {
  late Future<List<Program>> programData;

  @override
  void initState() {
    programData = getProgramInfo(); // استدعاء دالة جلب البيانات
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder<List<Program>>(
            future: programData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'.tr()); // رسالة خطأ مترجمة
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No programs available.'.tr()); // رسالة مترجمة
              } else {
                return Expanded(
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final program = snapshot.data![index];
                        return ProgramsItems(
                          title: program.category.tr(), // ترجمة الفئة
                          description: program.name.tr(), // ترجمة الاسم
                          lessonsCount: program.lesson.toString(), // عدد الدروس
                          imagePath: AssetPaths.imageFrame122, // استخدام مسار الصورة من Constants
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

class ProgramsItems extends StatelessWidget {
  const ProgramsItems({
    super.key,
    required this.title,
    required this.description,
    required this.lessonsCount,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String lessonsCount;
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium,), // استخدام bodyMedium
                    Text(description, style: Theme.of(context).textTheme.bodyLarge,), // استخدام bodyLarge
                    Text('$lessonsCount Lesson', style: Theme.of(context).textTheme.labelLarge,) // استخدام labelLarge
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
