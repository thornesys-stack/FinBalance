import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 一个可切换的选项。
class AuthTabOption<T> {
  final T value;

  final String label;

  const AuthTabOption(this.value, this.label);
}

/// 认证页的分段切换控件。
///
/// 两种形态：
///   - 默认（`dense: false`）：滑块样式，用于「邮箱 / 手机号」这种平级主切换；
///   - `dense: true`：下划线样式，用于「验证码 / 密码」这种从属的次要切换。
///
/// 为什么不用 Material 自带的 SegmentedButton：
///   它的选中态是"填充色 + 边框"，在只有两个选项、又紧挨着输入框的场景里
///   视觉重量偏大，会跟下面的主按钮抢注意力。
class AuthTabs<T> extends StatelessWidget {
  final List<AuthTabOption<T>> options;

  final T selected;

  final ValueChanged<T> onChanged;

  /// 次要样式（下划线）。
  final bool dense;

  final bool enabled;

  const AuthTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.dense = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return dense ? _buildDense(context) : _buildSegmented(context);
  }

  Widget _buildSegmented(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),

      // 轨道：淡蓝半透明 + 细描边。
      // 浅色底上不能用白色填充（等于没画），也不该用实心灰 ——
      // 它是卡片内部的一个控件，不该独立成块。
      decoration: BoxDecoration(
        color: AppColors.coolMid.withValues(alpha: 0.07),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: AppColors.coolMid.withValues(alpha: 0.12)),
      ),

      child: Row(
        children:
            options.map((option) {
              final isSelected = option.value == selected;

              return Expanded(
                child: GestureDetector(
                  // opaque：让整块 42px 高的区域都可点，
                  // 而不是只有文字那几个像素。
                  behavior: HitTestBehavior.opaque,

                  onTap: enabled ? () => onChanged(option.value) : null,

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),

                    height: 42,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      // 选中的滑块用纯白：它要比轨道白，
                      // 才读得出「浮起来的那一片玻璃」。
                      color: isSelected ? Colors.white : Colors.transparent,

                      borderRadius: BorderRadius.circular(11),

                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.coolDeep.withValues(
                                    alpha: 0.10,
                                  ),

                                  blurRadius: 8,

                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),

                    child: Text(
                      option.label,

                      style: TextStyle(
                        fontSize: 14,

                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,

                        color:
                            isSelected
                                ? AppColors.coolMid
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDense(BuildContext context) {
    return Row(
      children:
          options.map((option) {
            final isSelected = option.value == selected;

            return Padding(
              padding: const EdgeInsets.only(right: 20),

              child: GestureDetector(
                behavior: HitTestBehavior.opaque,

                onTap: enabled ? () => onChanged(option.value) : null,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,

                      style: TextStyle(
                        fontSize: 13.5,

                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,

                        color:
                            isSelected
                                ? AppColors.coolMid
                                : AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // 下划线用颜色切换而不是宽度动画：改宽度会推动
                    // 相邻标签左右移动，切换时整行都在抖。
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),

                      height: 2,

                      width: 18,

                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.coolMid : Colors.transparent,

                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
