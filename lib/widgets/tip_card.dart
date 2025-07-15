import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/tip_model.dart';
import 'package:easy_digital_security/screens/tip_detail_screen.dart'; // استيراد شاشة التفاصيل الجديدة

class TipCard extends StatelessWidget {
  final TipModel tip; // النصيحة المراد عرضها

  const TipCard({super.key, required this.tip, required Null Function() onTap});

  @override
  Widget build(BuildContext context) {
    // تحديد اللغة الحالية لعرض النص الصحيح
    final isArabic = context.locale.languageCode == 'ar';
    final title = isArabic ? tip.titleAr : tip.titleEn;

    // الحصول على BorderRadius من الثيم بأمان
    final BorderRadius? cardBorderRadius = (Theme.of(context).cardTheme.shape is RoundedRectangleBorder)
        ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.of(context))
        : null;

    return GestureDetector(
      onTap: () {
        // الانتقال إلى شاشة تفاصيل النصيحة عند النقر
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TipDetailScreen(tip: tip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 16), // هامش أصغر
        width: double.infinity ,// عرض أصغر للبطاقة
        height: 220, // ارتفاع أصغر للبطاقة
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color, // لون البطاقة من الثيم
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08), // ظل أكثر نعومة
              blurRadius: 8, // تأثير ضبابي أقل
              spreadRadius: 0.5, // انتشار أقل
              offset: const Offset(0, 4), // إزاحة للأسفل
            )
          ],
          borderRadius: cardBorderRadius ?? BorderRadius.circular(10), // حواف دائرية أصغر
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الصورة
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), // حواف دائرية أصغر
                topRight: Radius.circular(10), // حواف دائرية أصغر
              ),
              child: Image.network(
                tip.imageUrl,
                fit: BoxFit.cover,
                height: 150, // ارتفاع الصورة أصغر
                width: double.infinity, // الصورة تملأ العرض المتاح
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 90, // ارتفاع الصورة أصغر
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceVariant, // استخدام لون الثيم لخلفية التحميل
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: Theme.of(context).colorScheme.primary, // استخدام لون الثيم لمؤشر التحميل
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 90, // ارتفاع الصورة أصغر
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceVariant, // استخدام لون الثيم لخلفية الخطأ
                    child: Center(
                      child: Icon(Icons.broken_image, size: 25, color: Theme.of(context).colorScheme.error), // أيقونة أصغر ولون من الثيم
                    ),
                  );
                },
              ),
            ),
            // قسم النص (العنوان فقط)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10), // مسافة بادئة أصغر للنص
                alignment: Alignment.centerLeft, // محاذاة النص لليسار
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith( // تم التعديل هنا: استخدام bodyMedium لخط أصغر
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface, // لون النص من الثيم
                    fontFamily: 'Lora', // التأكيد على استخدام خط Lora
                  ),
                  maxLines: 3, // السماح بسطرين أو ثلاثة للعناوين الطويلة
                  overflow: TextOverflow.ellipsis, // إضافة علامة الحذف للنصوص الطويلة
                  textAlign: TextAlign.start, // محاذاة النص لليسار
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
