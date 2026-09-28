import 'dart:ui';

import 'package:flutter/material.dart';

import '../features/home/presentation/home_page.dart';
import '../features/transactions/presentation/transactions_page.dart';
import '../features/ai/presentation/ai_page.dart';
import '../features/analysis/presentation/analysis_page.dart';
import '../features/account/presentation/account_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _items = [
    (Icons.home_rounded, '首页'),
    (Icons.receipt_long_rounded, '交易'),
    (Icons.auto_awesome_rounded, 'AI'),
    (Icons.bar_chart_rounded, '分析'),
    (Icons.person_outline_rounded, '账户'),
  ];

  final _pages = const [
    HomePage(),
    TransactionsPage(),
    AiPage(),
    AnalysisPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 92),
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _buildNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FC).withOpacity(0.9),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '智衡',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'FinBalance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA4B5),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '消息',
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 28,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.75)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 25,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              _items.length,
              (index) => Expanded(
                child: _NavigationItem(
                  icon: _items[index].$1,
                  label: _items[index].$2,
                  selected: _currentIndex == index,
                  onTap: () => setState(() => _currentIndex = index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 58,
          height: 68,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE8EEFF).withOpacity(0.85)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25,
                color: selected
                    ? const Color(0xFF3157E8)
                    : const Color(0xFF8FA2C8),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF3157E8)
                      : const Color(0xFF8FA2C8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
