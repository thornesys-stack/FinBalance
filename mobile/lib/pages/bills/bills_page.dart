import 'dart:ui';

import 'package:flutter/material.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

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
          // 页面标题
          const Text(
            '我的账单',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
              height: 1.15,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            '2026年09月',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF98A2B3),
            ),
          ),

          const SizedBox(height: 18),
          // 月度账单概览
          _buildOverviewCard(),

          const SizedBox(height: 30),
          // 消费记录
          const Text(
            '消费记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),

          const SizedBox(height: 13),

          _buildBillItem(
            icon: Icons.restaurant_rounded,
            iconColor: const Color(0xFF4385F5),
            iconBackground: const Color(0xFFE3F0FF),
            title: '餐饮',
            description: '今天 12:30',
            amount: '-¥38.00',
          ),

          const SizedBox(height: 10),

          _buildBillItem(
            icon: Icons.shopping_bag_rounded,
            iconColor: const Color(0xFF725CE6),
            iconBackground: const Color(0xFFEDE9FF),
            title: '购物',
            description: '昨天 18:42',
            amount: '-¥128.00',
          ),

          const SizedBox(height: 10),

          _buildBillItem(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF2897E6),
            iconBackground: const Color(0xFFE0F3FF),
            title: '交通',
            description: '09月23日 08:15',
            amount: '-¥16.00',
          ),

          const SizedBox(height: 10),

          _buildBillItem(
            icon: Icons.movie_rounded,
            iconColor: const Color(0xFF2BAFA2),
            iconBackground: const Color(0xFFE2F8F4),
            title: '娱乐',
            description: '09月22日 20:30',
            amount: '-¥58.00',
          ),

          const SizedBox(height: 10),

          _buildBillItem(
            icon: Icons.local_cafe_rounded,
            iconColor: const Color(0xFF4B8FD8),
            iconBackground: const Color(0xFFE5F1FF),
            title: '咖啡',
            description: '09月22日 14:20',
            amount: '-¥25.00',
          ),

          const SizedBox(height: 10),

          _buildBillItem(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF2DB9A5),
            iconBackground: const Color(0xFFE5FAF6),
            title: '工资收入',
            description: '09月20日 09:00',
            amount: '+¥8,500.00',
            isIncome: true,
          ),
        ],
      ),
    );
  }
  // 月度账单概览
  Widget _buildOverviewCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            18,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.76),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withOpacity(0.88),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '本月支出',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF98A2B3),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                '¥4,230.00',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      title: '本月收入',
                      amount: '¥8,500.00',
                      color: const Color(0xFF2DB9A5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOverviewItem(
                      title: '本月结余',
                      amount: '¥4,270.00',
                      color: const Color(0xFF4385F5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // 概览数据
  Widget _buildOverviewItem({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  // 单条账单
  Widget _buildBillItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String description,
    required String amount,
    bool isIncome = false,
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
          height: 72,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
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
                  size: 21,
                ),
              ),

              const SizedBox(width: 13),
              // 名称与时间
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF182230),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFB0BAC9),
                      ),
                    ),
                  ],
                ),
              ),
              // 金额
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isIncome
                      ? const Color(0xFF2DB9A5)
                      : const Color(0xFF101828),
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
}