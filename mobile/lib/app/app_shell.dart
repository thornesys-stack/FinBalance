import 'package:flutter/material.dart';

import '../features/account/data/account_repository.dart';
import '../features/account/presentation/account_page.dart';
import '../features/analysis/presentation/analysis_page.dart';
import '../features/ai/presentation/ai_page.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/home/presentation/home_page.dart';
import '../features/transaction/data/transaction_repository.dart';
import '../features/transaction/presentation/transaction_page.dart';

class AppShell extends StatefulWidget {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;

  /// 传给账户页：那里要展示当前登录身份，并提供登出入口。
  final AuthController authController;

  const AppShell({
    super.key,
    required this.accountRepository,
    required this.transactionRepository,
    required this.authController,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePage(),
      TransactionPage(transactionRepository: widget.transactionRepository),
      const AnalysisPage(),
      const AiPage(),
      AccountPage(
        accountRepository: widget.accountRepository,
        authController: widget.authController,
      ),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: _onDestinationSelected,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),

          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '账单',
          ),

          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: '分析',
          ),

          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),

          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: '账户',
          ),
        ],
      ),
    );
  }
}
