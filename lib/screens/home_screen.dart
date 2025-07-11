import 'package:flutter/material.dart';
import '../models/tip_model.dart';
import '../widgets/tip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Tip dailyTip;

  final List<Tip> tips = [
    Tip(
      id: '1',
      title: 'Password Strength',
      description: 'Always use strong passwords with a mix of characters.',
    ),
    Tip(
      id: '2',
      title: 'Phishing Awareness',
      description: 'Don’t click on suspicious links in emails or messages.',
    ),
    Tip(
      id: '3',
      title: 'Update Software',
      description: 'Keep your software up-to-date to avoid vulnerabilities.',
    ),
  ];

  int tipIndex = 0;

  @override
  void initState() {
    super.initState();
    dailyTip = tips[tipIndex];
  }

  void _showNextTip() {
    setState(() {
      tipIndex = (tipIndex + 1) % tips.length;
      dailyTip = tips[tipIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRTL ? 'نصائح الأمان الرقمية' : 'Digital Security Tips',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            tooltip: isRTL ? 'الاختبارات' : 'Quizzes',
            onPressed: () {
              Navigator.pushNamed(context, '/quiz');
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: isRTL ? 'تغيير اللغة' : 'Change Language',
            onPressed: () {
              // TODO: إضافة تبديل اللغة (مثلاً عبر Provider أو GetX)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: TipCard(tip: dailyTip),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text(isRTL ? 'التالي' : 'Next Tip'),
              onPressed: _showNextTip,
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
