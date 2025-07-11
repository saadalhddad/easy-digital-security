import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Digital Security'),
      ),
      body: const Center(
        child: Text('مرحبًا بك في Easy Digital Security!'),
      ),
    );
  }
}
