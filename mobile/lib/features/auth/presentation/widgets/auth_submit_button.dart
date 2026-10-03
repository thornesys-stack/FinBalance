import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'glass_surface.dart';

/// 认证页的主操作按钮。
///
/// 冷色渐变玻璃：填充是半透明的蓝，顶部有一道白光，边缘一圈高光描边。
/// 文字用纯白 —— 填充只有 85% 不透明，底色最亮的地方也能留住 4.5:1 以上。
///
/// 提交中把按钮**置灰**而不是保留可点状态：
/// 登录请求要打一次网络，双击很容易发出两个请求，
/// 服务端的 refresh token 轮换策略会让后到的那个把前一个作废。
class AuthSubmitButton extends StatelessWidget {
  final String label;

  final bool isSubmitting;

  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      height: 52,

      radius: 15,

      gradient: AppColors.authPrimaryGradient,

      borderColor: Colors.white.withValues(alpha: 0.34),

      // 蓝色投影而不是黑色：浅色底上投灰黑会脏，投本色则像一层透光的晕。
      // 透明度比压在深色底时要低 —— 底色越亮，同一个 alpha 越显重。
      shadows: [
        BoxShadow(
          color: AppColors.coolMid.withValues(alpha: 0.26),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],

      onPressed: isSubmitting ? null : onPressed,

      child:
          isSubmitting
              ? const SizedBox(
                width: 20,
                height: 20,

                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
              : Text(
                label,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
    );
  }
}
