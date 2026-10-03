import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'glass_surface.dart';
import 'google_logo.dart';

/// 「使用 Google 继续」按钮。
///
/// 视觉上与主按钮（冷色渐变玻璃）明显区分，但仍然是玻璃：
/// 淡蓝半透明填充 + 细描边 + 顶部反光，只是不带浓度。
/// 这样两条登录路径一眼能看出是平级的两个入口，而不是「主操作 + 附属链接」。
///
/// 保持浅色底是 Google 品牌规范的硬要求 —— 官方按钮不允许用第三方主色填充。
class GoogleSignInButton extends StatelessWidget {
  final bool isSubmitting;

  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      height: 52,

      radius: 15,

      // 淡蓝半透明 + 细描边：在浅色底上，玻璃只能靠"极淡的色 + 一圈细边"表达。
      // 用白色填充会和卡片（本身也是浅色）糊成一片，看过去像没画。
      fill: AppColors.coolMid.withValues(alpha: 0.07),

      borderColor: AppColors.coolMid.withValues(alpha: 0.18),

      shadows: [
        BoxShadow(
          color: AppColors.coolDeep.withValues(alpha: 0.07),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],

      onPressed: isSubmitting ? null : onPressed,

      child:
          isSubmitting
              ? SizedBox(
                width: 18,
                height: 18,

                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.coolMid,
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: const [
                  GoogleLogo(size: 18),

                  SizedBox(width: 10),

                  Text(
                    '使用 Google 继续',

                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
    );
  }
}
