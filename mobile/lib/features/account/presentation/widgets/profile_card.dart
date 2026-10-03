import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/auth_user.dart';

/// 账户页顶部的身份卡片。
///
/// 它同时承担两个职责：
///   1. 让用户确认"现在登录的是谁"（多账号 / 换了测试环境时很需要）；
///   2. 承载登出入口。
///
/// 之所以两者放一起：登出是一个有后果的操作，紧邻"你是谁"展示，
/// 用户点下去之前能顺手核对一眼账号，比把它塞进某个二级设置页更安全。
class ProfileCard extends StatelessWidget {
  final AuthUser? user;

  /// 非错误类提示，例如冷启动时"当前离线，展示的是上次同步的数据"。
  final String? notice;

  final bool isLoggingOut;

  final VoidCallback onLogout;

  const ProfileCard({
    super.key,
    required this.user,
    required this.notice,
    required this.isLoggingOut,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final current = user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,

                  backgroundColor: AppColors.primaryLight,

                  child: Text(
                    current?.initial ?? '?',

                    // 用 runes 取首字符在 AuthUser.initial 里已经处理过，
                    // 这里只负责渲染，不再做截断。
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current?.displayName ?? '未登录',

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: textTheme.titleMedium,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        current?.email ?? '登录状态已失效',

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (current != null) ...[
              const SizedBox(height: 18),

              _InfoRow(label: '主货币', value: current.baseCurrency),

              const SizedBox(height: 10),

              _InfoRow(label: '界面语言', value: current.locale),

              const SizedBox(height: 10),

              _InfoRow(label: '时区', value: current.timeZone),
            ],

            if (notice != null) ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: AppColors.warningSoft,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        notice!,

                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 32),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: isLoggingOut ? null : onLogout,

                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.expense,

                  side: const BorderSide(color: AppColors.expense),

                  minimumSize: const Size(0, 46),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                icon:
                    isLoggingOut
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.logout_rounded, size: 18),

                label: Text(isLoggingOut ? '正在退出…' : '退出登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「标签 —— 值」一行。
class _InfoRow extends StatelessWidget {
  final String label;

  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(width: 76, child: Text(label, style: textTheme.bodySmall)),

        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
