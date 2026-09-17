import 'package:flutter/material.dart';

import 'pages/home/home_page.dart';

void main() {
  runApp(const FinBalanceApp());
}

class FinBalanceApp extends StatelessWidget {
  const FinBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '智衡 FinBalance',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3157E8),
        ),
      ),
      home: const HomePage(),
    );
  }
}