import 'dart:ui';

import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildPeriodSelector(),

          const SizedBox(height: 18),

          _buildOverviewCard(),

          const SizedBox(height: 22),

          _buildSectionTitle(
            '收支趋势',
            '本期财务变化情况',
          ),

          const SizedBox(height: 12),

          _buildTrendCard(),

          const SizedBox(height: 22),

          _buildSectionTitle(
            '消费结构',
            '了解你的资金主要流向',
          ),

          const SizedBox(height: 12),

          _buildCategoryCard(),

          const SizedBox(height: 22),

          _buildSectionTitle(
            '财务指标',
            '本期核心数据',
          ),

          const SizedBox(height: 12),

          _buildMetrics(),

          const SizedBox(height: 22),

          _buildInsightCard(),
        ],
      ),
    );
  }

  // ============================================================
  // 顶部标题
  // ============================================================

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '财务分析',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 5),
        Text(
          '从数据中了解你的财务状况',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8B95A7),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 时间选择
  // ============================================================

  Widget _buildPeriodSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 19,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  '2026/08/19 - 2026/09/17',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: Color(0xFF9AA4B5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 财务总览
  // ============================================================

  Widget _buildOverviewCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3157E8).withValues(alpha: 0.92),
                const Color(0xFF6380F0).withValues(alpha: 0.86),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '本期结余',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                '¥4,270.00',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      '收入',
                      '¥8,500.00',
                    ),
                  ),
                  Expanded(
                    child: _buildOverviewItem(
                      '支出',
                      '¥4,230.00',
                    ),
                  ),
                  Expanded(
                    child: _buildOverviewItem(
                      '储蓄率',
                      '50.2%',
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

  Widget _buildOverviewItem(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Section 标题
  // ============================================================

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 2,
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9AA4B5),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 收支趋势
  // ============================================================

  Widget _buildTrendCard() {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildLegend(
                '收入',
                const Color(0xFF3157E8),
              ),
              const SizedBox(width: 18),
              _buildLegend(
                '支出',
                const Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: CustomPaint(
              painter: _TrendPainter(),
              child: const SizedBox(
                width: double.infinity,
              ),
            ),
          ),
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '08/19',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9AA4B5),
                ),
              ),
              Text(
                '08/29',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9AA4B5),
                ),
              ),
              Text(
                '09/08',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9AA4B5),
                ),
              ),
              Text(
                '09/17',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9AA4B5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    String text,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 消费结构
  // ============================================================

  Widget _buildCategoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          _buildCategoryRow(
            '餐饮',
            '¥1,280.00',
            30.3,
            Icons.restaurant_rounded,
          ),
          const SizedBox(height: 15),
          _buildCategoryRow(
            '购物',
            '¥860.00',
            20.3,
            Icons.shopping_bag_rounded,
          ),
          const SizedBox(height: 15),
          _buildCategoryRow(
            '交通',
            '¥420.00',
            9.9,
            Icons.directions_car_rounded,
          ),
          const SizedBox(height: 15),
          _buildCategoryRow(
            '娱乐',
            '¥360.00',
            8.5,
            Icons.movie_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String name,
    String amount,
    double percentage,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF5874D8),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor:
                      const Color(0xFFE9EEF7),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C83DF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 财务指标
  // ============================================================

  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.savings_rounded,
            title: '储蓄率',
            value: '50.2%',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.trending_down_rounded,
            title: '日均支出',
            value: '¥141',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.receipt_long_rounded,
            title: '账单数',
            value: '48',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFF6079D7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9AA4B5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 财务洞察
  // ============================================================

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.insights_rounded,
            size: 25,
            color: Color(0xFF3157E8),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '财务洞察',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3157E8),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '当前储蓄率保持在较为健康的水平。餐饮支出占总支出的比例较高，可以适当关注非必要餐饮消费。',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.55,
                    color: Color(0xFF5E6B82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 收支趋势图
// ============================================================

class _TrendPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final incomePaint = Paint()
      ..color = const Color(0xFF3157E8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final expensePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = const Color(0xFFE8EDF5)
      ..strokeWidth = 1;

    // 网格线
    for (int i = 0; i < 4; i++) {
      final double y =
          size.height * i / 3;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 收入曲线
    final incomePath = Path();

    incomePath.moveTo(
      0,
      size.height * 0.62,
    );

    incomePath.cubicTo(
      size.width * 0.15,
      size.height * 0.55,
      size.width * 0.20,
      size.height * 0.32,
      size.width * 0.34,
      size.height * 0.40,
    );

    incomePath.cubicTo(
      size.width * 0.50,
      size.height * 0.48,
      size.width * 0.57,
      size.height * 0.18,
      size.width * 0.70,
      size.height * 0.28,
    );

    incomePath.cubicTo(
      size.width * 0.82,
      size.height * 0.36,
      size.width * 0.90,
      size.height * 0.14,
      size.width,
      size.height * 0.20,
    );

    canvas.drawPath(
      incomePath,
      incomePaint,
    );

    // 支出曲线
    final expensePath = Path();

    expensePath.moveTo(
      0,
      size.height * 0.75,
    );

    expensePath.cubicTo(
      size.width * 0.16,
      size.height * 0.65,
      size.width * 0.25,
      size.height * 0.70,
      size.width * 0.37,
      size.height * 0.58,
    );

    expensePath.cubicTo(
      size.width * 0.52,
      size.height * 0.46,
      size.width * 0.61,
      size.height * 0.68,
      size.width * 0.73,
      size.height * 0.55,
    );

    expensePath.cubicTo(
      size.width * 0.84,
      size.height * 0.45,
      size.width * 0.92,
      size.height * 0.58,
      size.width,
      size.height * 0.48,
    );

    canvas.drawPath(
      expensePath,
      expensePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _TrendPainter oldDelegate,
  ) {
    return false;
  }
}