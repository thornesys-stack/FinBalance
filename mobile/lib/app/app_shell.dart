import 'dart:ui';

import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    _PlaceholderPage(title: '账单'),
    _PlaceholderPage(title: '分析'),
    _PlaceholderPage(title: 'AI'),
    _PlaceholderPage(title: '我的'),
  ];
  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.bar_chart_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_outline_rounded,
  ];
  final List<String> _labels = const [
    '首页',
    '账单',
    '分析',
    'AI',
    '我的',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: Stack(
        children: [
          // 页面内容
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 100,
              ),
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ),
          // 固定顶部栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
          // 底部磨砂导航栏
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _buildGlassNavigationBar(),
          ),
        ],
      ),
    );
  }
// 顶部固定栏
  Widget _buildTopBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          height: 100,

          padding: const EdgeInsets.only(
            left: 22,
            right: 22,
            top: 30,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FC).withOpacity(0.86),

            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.45),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧：智衡
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [

                    Text(
                      '智衡',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 1.0,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'FinBalance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9AA4B5),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
                // 右侧：消息
                GestureDetector(
                onTap: () {
                // 后续接入消息页面
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: const Color(0xFF111827),
                    ),
                    // 红色未读提示
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5C67),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
// 底部磨砂导航栏
  Widget _buildGlassNavigationBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),

        child: Container(
          height: 82,

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),

            borderRadius: BorderRadius.circular(30),

            border: Border.all(
              color: Colors.white.withOpacity(0.75),
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: List.generate(
              _labels.length,
              (index) => _buildNavigationItem(index),
            ),
          ),
        ),
      ),
    );
  }
// 导航按钮
  Widget _buildNavigationItem(int index) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },

        child: Center(
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),

            width: 58,
            height: 68,

            padding: const EdgeInsets.symmetric(
              vertical: 7,
            ),

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
                  _icons[index],
                  size: 25,
                  color: selected
                      ? const Color(0xFF3157E8)
                      : const Color(0xFF8FA2C8),
                ),

                const SizedBox(height: 4),

                Text(
                  _labels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF3157E8)
                        : const Color(0xFF8FA2C8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// 临时页面
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}