import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // قيمة التقدم (من 0.0 إلى 1.0)
  final Color backgroundColor; // لون خلفية الشريط
  final Color progressColor; // لون شريط التقدم
  final double height; // ارتفاع الشريط
  final String? label; // نص اختياري لعرضه على الشريط

  const ProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.height = 10.0,
    this.label, required BorderRadius borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2), // حواف دائرية
      ),
      child: Stack(
        children: [
          // شريط التقدم الفعلي
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0), // ضمان أن القيمة بين 0 و 1
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          // النص (إذا كان موجوداً)
          if (label != null)
            Center(
              child: Text(
                label!,
                style: TextStyle(
                  color: Colors.white, // لون النص
                  fontSize: height * 0.8, // حجم الخط بناءً على ارتفاع الشريط
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
