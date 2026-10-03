import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'glass_surface.dart';

/// 认证页顶部标题区。
///
/// 它**不带容器** —— 字直接压在整页底纹上。这是刻意的：
/// 国际化登录页里标题通常不装盒子，容器一多页面就碎。
///
/// 文字用深冷色（[AppColors.coolDeep]）而不是纯黑：
/// 底色是浅冷调，纯黑压上去会显得生硬、和整页的色调脱节；
/// coolDeep 与底色的对比度在 12:1 以上，读起来没有任何负担。
class AuthHeroHeader extends StatelessWidget {
  final String title;

  final String subtitle;

  /// 是否显示 FinBalance 字标（注册页可以省掉以让出纵向空间）。
  final bool showWordmark;

  const AuthHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        if (showWordmark) ...[
          Row(
            children: [
              // 品牌标：白玻璃 + 浅蓝描边。
              // 在浅色底上，玻璃的"厚度"只能靠描边和反光表达 ——
              // 用纯白填充会和背景糊在一起，看起来像没画。
              GlassSurface(
                radius: 11,

                blur: 12,

                fill: Colors.white.withValues(alpha: 0.72),

                borderColor: AppColors.coolBright.withValues(alpha: 0.30),

                child: const SizedBox(
                  width: 34,
                  height: 34,

                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.coolMid,
                    size: 19,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Text(
                'FinBalance',

                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.coolDeep,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],

        Text(
          title,

          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.coolDeep,
            fontSize: 26,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,

          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
