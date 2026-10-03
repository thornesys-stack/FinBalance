import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 一条居中带字的横线，例如「———— 或 ————」。
///
/// 用来把「邮箱/手机号登录」和「Google 登录」在语义上分开：
/// 它们是各自独立的两条路径，不是同一个表单的附加项。
///
/// 线的颜色走冷色而不是中性灰：中性灰压在冷调卡片上会显脏，
/// 用底色的低透明版本则始终和整页色调一致。
class AuthOrDivider extends StatelessWidget {
  final String label;

  const AuthOrDivider({super.key, this.label = '或'});

  @override
  Widget build(BuildContext context) {
    final line = Container(
      height: 1,
      color: AppColors.coolDeep.withValues(alpha: 0.10),
    );

    return Row(
      children: [
        Expanded(child: line),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ),

        Expanded(child: line),
      ],
    );
  }
}
