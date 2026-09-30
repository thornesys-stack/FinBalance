import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'app_theme.dart';

class FinBalanceApp extends StatelessWidget {
  const FinBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智衡 FinBalance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}