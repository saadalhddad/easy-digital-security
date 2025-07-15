import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProgramsBar extends StatelessWidget {
  const ProgramsBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge, // استخدام titleLarge
          ),
          TextButton(
            onPressed: () {
              // يمكن إضافة منطق "View all" هنا
            },
            child: Row(
              children: [
                Text(
                  'View all'.tr(),
                  style: Theme.of(context).textTheme.labelLarge, // استخدام labelLarge
                ),
                Icon(Icons.arrow_forward, color: Theme.of(context).textTheme.labelLarge?.color), // استخدام لون الخط من الثيم
              ],
            ),
          ),
        ],
      ),
    );
  }
}
