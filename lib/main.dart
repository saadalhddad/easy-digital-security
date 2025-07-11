import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EasyDigitalSecurityApp());
}

class EasyDigitalSecurityApp extends StatelessWidget {
  const EasyDigitalSecurityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Digital Security',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
