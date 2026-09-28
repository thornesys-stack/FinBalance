import 'package:flutter/material.dart';

import 'app_shell.dart';
import '../core/theme/app_theme.dart';

class FinBalanceApp extends StatelessWidget {
  const FinBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '智衡 FinBalance',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
