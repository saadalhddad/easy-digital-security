import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ButtonInfo extends StatelessWidget {
  const ButtonInfo({
    super.key,
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // يمكن إضافة منطق النقر هنا
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: 48,
        width: MediaQuery.of(context).size.width * 0.45, // جعل العرض أكثر استجابة
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.primary)), // استخدام لون الثيم
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary, // استخدام لون الثيم
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium, // استخدام bodyMedium
            )
          ],
        ),
      ),
    );
  }
}
