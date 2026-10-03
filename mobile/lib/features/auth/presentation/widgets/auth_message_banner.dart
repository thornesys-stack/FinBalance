import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'glass_surface.dart';

/// 认证页里的一条横幅提示。
///
/// 为什么不用 SnackBar：
///   登录/注册失败时错误信息需要**一直留在屏幕上**直到用户改正 ——
///   SnackBar 几秒后自己消失，用户还没看清就没了，
///   而这一类错误（"邮箱或密码不正确"）恰恰是需要对着表单反复核对的。
///
/// 配色：错误走语义红，普通提示走冷色。
///   红色是**语义**不是装饰，改成冷色会让"密码错误"看起来像一条普通说明；
///   但它同样是半透明 + 描边的玻璃形态，和整页材质一致，不会显得是贴上去的。
class AuthMessageBanner extends StatelessWidget {
  final String message;

  /// true = 错误（红），false = 一般提示（冷色）。
  final bool isError;

  const AuthMessageBanner({
    super.key,
    required this.message,
    this.isError = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isError ? AppColors.expense : AppColors.coolMid;

    return GlassSurface(
      radius: 14,

      fill: accent.withValues(alpha: isError ? 0.10 : 0.09),

      borderColor: accent.withValues(alpha: 0.22),

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 18,
            color: accent,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,

              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: accent, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
