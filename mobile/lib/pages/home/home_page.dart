import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        28,
        8,
        28,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 财务概览
          const Text(
            '本期财务概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '2026/08/19 - 2026/09/17',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 18),

          // 本期结余
          _buildBalanceCard(),

          const SizedBox(height: 16),

          // 收入 / 支出
          Row(
            children: [
              Expanded(
                child: _buildMoneyCard(
                  title: '收入',
                  amount: '¥8,500.00',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: const Color(0xFF2DB9A5),
                  iconBackground: const Color(0xFFE5FAF6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMoneyCard(
                  title: '支出',
                  amount: '¥4,230.00',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFFFF5D7A),
                  iconBackground: const Color(0xFFFFEAF0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 消费分类
          const Text(
            '消费分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 13),

          _buildCategoryItem(
            icon: Icons.restaurant_rounded,
            name: '餐饮',
            amount: '¥1,280.00',
            percentage: '30.3%',
            progress: 0.72,
            iconColor: const Color(0xFF4385F5),
            iconBackground: const Color(0xFFE3F0FF),
          ),
          const SizedBox(height: 10),

          _buildCategoryItem(
            icon: Icons.shopping_bag_rounded,
            name: '购物',
            amount: '¥860.00',
            percentage: '20.3%',
            progress: 0.52,
            iconColor: const Color(0xFF725CE6),
            iconBackground: const Color(0xFFEDE9FF),
          ),
          const SizedBox(height: 10),

          _buildCategoryItem(
            icon: Icons.directions_car_rounded,
            name: '交通',
            amount: '¥420.00',
            percentage: '9.9%',
            progress: 0.31,
            iconColor: const Color(0xFF2897E6),
            iconBackground: const Color(0xFFE0F3FF),
          ),
          const SizedBox(height: 10),

          _buildCategoryItem(
            icon: Icons.movie_rounded,
            name: '娱乐',
            amount: '¥360.00',
            percentage: '8.5%',
            progress: 0.27,
            iconColor: const Color(0xFF2BAFA2),
            iconBackground: const Color(0xFFE2F8F4),
          ),

          const SizedBox(height: 30),

          // AI 财务摘要
          const Text(
            'AI 财务摘要',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),

          const SizedBox(height: 13),

          _buildAiCard(),
        ],
      ),
    );
  }

  // 本期结余
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      height: 124,
      padding: const EdgeInsets.fromLTRB(
        22,
        15,
        22,
        14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF3157E8),
            Color(0xFF6383F1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3157E8).withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本期结余',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '¥4,270.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '较上期增加 8.6%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 收入 / 支出
  Widget _buildMoneyCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          height: 112,
          padding: const EdgeInsets.fromLTRB(
            17,
            10,
            17,
            10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF98A2B3),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 消费分类
  Widget _buildCategoryItem({
    required IconData icon,
    required String name,
    required String amount,
    required String percentage,
    required double progress,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          height: 76,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.88),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),

              // 分类内容
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF182230),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // 进度条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 5,
                            width: double.infinity,
                            color: const Color(0xFFDCE7F6),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: iconColor,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      '占支出 $percentage',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFB0BAC9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 金额
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(width: 3),

              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF91A4C7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AI 财务摘要
  Widget _buildAiCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          height: 124,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EFFF).withOpacity(0.76),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF5276E8),
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),

              const Expanded(
                child: Text(
                  '本期消费整体较为稳定，餐饮支出占比较高。\n'
                  '建议下个月适当控制非必要餐饮消费，\n'
                  '并提前设置月度预算。',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Color(0xFF34456D),
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF91A4C7),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
