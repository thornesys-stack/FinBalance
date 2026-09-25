import 'dart:ui';

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

          _buildProfileCard(),

          const SizedBox(height: 22),

          _buildSectionTitle('账户与数据'),

          const SizedBox(height: 12),

          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: '账单数据',
              subtitle: '管理你的账单数据',
              onTap: () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.file_upload_outlined,
              title: '导入账单',
              subtitle: '导入微信、支付宝等账单',
              onTap: () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.file_download_outlined,
              title: '数据导出',
              subtitle: '导出 Excel / PDF 财务报告',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          _buildSectionTitle('偏好设置'),

          const SizedBox(height: 12),

          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: '消息通知',
              subtitle: '管理消息与提醒',
              onTap: () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.calendar_month_outlined,
              title: '统计周期',
              subtitle: '设置你的月度统计日期',
              onTap: () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.palette_outlined,
              title: '主题设置',
              subtitle: '调整应用外观',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 20),

          _buildSectionTitle('关于'),

          const SizedBox(height: 12),

          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              title: '关于智衡',
              subtitle: 'FinBalance',
              onTap: () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: '帮助与反馈',
              subtitle: '遇到问题？告诉我们',
              onTap: () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: '隐私与服务协议',
              subtitle: '了解数据使用与隐私保护',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          _buildVersion(),

          const SizedBox(height: 10),
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
          '我的',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 5),
        Text(
          '管理你的账户与 FinBalance',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8B95A7),
          ),
        ),
      ],
    );
  }
// 用户信息卡片
  Widget _buildProfileCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
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
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FinBalance 用户',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '开始管理你的个人财务',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
// Section 标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }
// 菜单卡片
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
// 菜单项目
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF6079D7),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AA4B5),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFA6B0C1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 68,
      ),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: const Color(0xFFE8EDF5),
      ),
    );
  }
// 版本信息
  Widget _buildVersion() {
    return const Center(
      child: Column(
        children: [
          Text(
            '智衡 FinBalance',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A7),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFB0B8C6),
            ),
          ),
        ],
      ),
    );
  }
}