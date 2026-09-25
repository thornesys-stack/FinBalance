import 'dart:ui';

import 'package:flutter/material.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

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

          _buildAiWelcomeCard(),

          const SizedBox(height: 22),

          _buildSectionTitle(
            '智能分析',
            'AI 根据你的财务数据生成洞察',
          ),

          const SizedBox(height: 12),

          _buildInsightCard(),

          const SizedBox(height: 22),

          _buildSectionTitle(
            '本期建议',
            '根据近期消费行为生成',
          ),

          const SizedBox(height: 12),

          _buildSuggestionCard(
            icon: Icons.restaurant_rounded,
            title: '关注餐饮支出',
            content:
                '本期餐饮支出约占总支出的 30.3%，建议适当减少非必要外卖和临时性餐饮消费。',
          ),

          const SizedBox(height: 10),

          _buildSuggestionCard(
            icon: Icons.account_balance_wallet_rounded,
            title: '建立月度预算',
            content:
                '当前收入与支出保持较好的平衡，可以尝试提前规划下个月的消费预算。',
          ),

          const SizedBox(height: 10),

          _buildSuggestionCard(
            icon: Icons.savings_rounded,
            title: '保持储蓄习惯',
            content:
                '当前储蓄率约为 50.2%，整体表现较为稳定，可以继续保持当前的储蓄习惯。',
          ),

          const SizedBox(height: 22),

          _buildSectionTitle(
            '你可以问我',
            '关于你的财务问题',
          ),

          const SizedBox(height: 12),

          _buildQuestionList(),

          const SizedBox(height: 22),

          _buildChatButton(),
        ],
      ),
    );
  }
// 顶部标题
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 财务助手',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 5),
        Text(
          '让 AI 帮你更好地理解自己的财务',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8B95A7),
          ),
        ),
      ],
    );
  }
// AI 欢迎卡片
  Widget _buildAiWelcomeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3157E8).withValues(alpha: 0.94),
                const Color(0xFF738CF1).withValues(alpha: 0.88),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      '你好，我是智衡 AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              const Text(
                '我可以根据你的收入、支出和消费习惯，帮助你分析财务状况，并给出更适合你的建议。',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: Color(0xFFB9FFD4),
                    ),
                    SizedBox(width: 7),
                    Text(
                      'AI 助手已准备就绪',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
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
// Section 标题
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
// AI 财务洞察
  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 20,
                  color: Color(0xFF3157E8),
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Text(
                  '本期财务洞察',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),

              const Text(
                'AI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7183C7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            '从本期数据来看，你的整体财务状态较为稳定。收入 ¥8,500.00，支出 ¥4,230.00，本期结余 ¥4,270.00。',
            style: TextStyle(
              fontSize: 13,
              height: 1.65,
              color: Color(0xFF5E6B82),
            ),
          ),

          const SizedBox(height: 11),

          const Text(
            '其中餐饮支出占比较高，可以作为下个月优化消费结构的主要方向。',
            style: TextStyle(
              fontSize: 13,
              height: 1.65,
              color: Color(0xFF5E6B82),
            ),
          ),
        ],
      ),
    );
  }
// 建议卡片
  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF6079D7),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.55,
                    color: Color(0xFF7A8497),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// 快捷问题
  Widget _buildQuestionList() {
    return Column(
      children: [
        _buildQuestion(
          '这个月我的钱主要花在哪里？',
          Icons.search_rounded,
        ),
        const SizedBox(height: 9),
        _buildQuestion(
          '下个月应该设置多少预算？',
          Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 9),
        _buildQuestion(
          '我的消费习惯有什么问题？',
          Icons.psychology_outlined,
        ),
        const SizedBox(height: 9),
        _buildQuestion(
          '怎样才能提高储蓄率？',
          Icons.trending_up_rounded,
        ),
      ],
    );
  }

  Widget _buildQuestion(
    String text,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF7183C7),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5E6B82),
              ),
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFFA6B0C1),
          ),
        ],
      ),
    );
  }
// 开始对话按钮
  Widget _buildChatButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          // 后续接入真正的 AI 对话页面
        },
        icon: const Icon(
          Icons.auto_awesome_rounded,
          size: 19,
        ),
        label: const Text(
          '开始与 AI 对话',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3157E8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}