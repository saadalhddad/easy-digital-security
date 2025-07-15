import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_digital_security/utils/constants.dart'; // لاستخدام AssetPaths

class EventsAndExperiences extends StatelessWidget {
  const EventsAndExperiences({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            EventsAndExperiencesItems(
              title: 'Working Parents'.tr(),
              description: 'Understanding of human behaviour'.tr(),
              lessonsCount: '13 Feb, Sunday '.tr(),
              imagePath: AssetPaths.imageYoga, // استخدام مسار الصورة من Constants
            ),
            EventsAndExperiencesItems(
              title: 'Working Parents'.tr(),
              description: 'Understanding of human behaviour'.tr(),
              lessonsCount: '13 Feb, Sunday'.tr(),
              imagePath: AssetPaths.imageYoga, // استخدام مسار الصورة من Constants
            ),
            // أضف المزيد من العناصر هنا
          ],
        ),
      ),
    );
  }
}

class EventsAndExperiencesItems extends StatelessWidget {
  const EventsAndExperiencesItems({
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
        width: 250, // يمكن جعلها أكثر استجابة باستخدام MediaQuery
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
                        Text(lessonsCount, style: Theme.of(context).textTheme.labelLarge,), // استخدام labelLarge
                        OutlinedButton(
                          style: Theme.of(context).outlinedButtonTheme.style, // استخدام ستايل OutlinedButton من الثيم
                          onPressed: () {},
                          child: Text('Book'.tr()), // ترجمة النص
                        )
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
