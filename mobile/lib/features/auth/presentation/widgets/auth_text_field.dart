import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 认证页统一样式的输入框。
///
/// 直接写 [TextFormField] 会有个容易忽略的坑：
/// 只要传了 `maxLength`，Flutter 默认在右下角画一个 `0/50` 计数器，
/// 在只有 5 个字段的表单里非常吵。这里统一压掉。
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;

  final String label;

  final IconData icon;

  final String? hint;

  final bool obscureText;

  final Widget? suffixIcon;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final Iterable<String>? autofillHints;

  final String? Function(String?)? validator;

  final bool enabled;

  final int? maxLength;

  final bool autocorrect;

  final FocusNode? focusNode;

  final ValueChanged<String>? onFieldSubmitted;

  final ValueChanged<String>? onChanged;

  /// 输入框内的前置控件（会随 label 一起浮动），例如手机号的区号选择器。
  ///
  /// 用 `prefixIcon` 槽位而不是把输入框塞进 Row：Row 里两个控件的高度
  /// 由各自内容决定，稍有差异就会出现"区号框比输入框矮 4px"这种错位；
  /// 放在同一个 InputDecoration 里，对齐由框架保证。
  final Widget? prefixIcon;

  /// 挂到内部 [TextFormField] 上的 key。
  ///
  /// 有了它才能**只校验某一个字段**：`Form.validate()` 会把整张表单
  /// 全标红，而"点获取验证码"时手机号还没填，不该连验证码框一起报错。
  final GlobalKey<FormFieldState<String>>? fieldKey;

  /// 字段下方的辅助说明（出错时由错误文案顶掉）。
  ///
  /// 交给 [InputDecoration.helperText] 而不是自己在字段下面拼一行：
  /// InputDecorator 原生按「有错误显示错误、没错误显示说明」切换，
  /// 自己拼的话两条文案会同时占位，表单高度还会因此跳一次。
  final String? helperText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.autocorrect = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.fieldKey,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,

      controller: controller,

      focusNode: focusNode,

      enabled: enabled,

      obscureText: obscureText,

      keyboardType: keyboardType,

      textInputAction: textInputAction,

      autofillHints: autofillHints,

      autocorrect: autocorrect,

      maxLength: maxLength,

      validator: validator,

      onFieldSubmitted: onFieldSubmitted,

      onChanged: onChanged,

      // 输入时立刻把上一次的错误提示清掉：用户已经在改了，
      // 错误横幅还挂着会让人以为自己改错了。
      decoration: InputDecoration(
        labelText: label,

        hintText: hint,

        counterText: '',

        helperText: helperText,

        // 说明可能较长（"目前仅支持邮箱注册，手机号注册待后端开放"），
        // 给到两行避免窄屏上被截断。
        helperMaxLines: 2,

        // 冷调次级色：它是说明而非警告。
        // 用中性灰会和整页冷调脱节，用主色又会抢走输入框的注意力。
        helperStyle: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AppColors.coolMid.withValues(alpha: 0.82),
        ),

        // 传了自定义前置控件时用它替换图标：区号本身比一个电话图标有用。
        prefixIcon: prefixIcon ?? Icon(icon, size: 20),

        // 默认的 prefixIcon 槽位是 48×48 的固定方块，装不下
        // 「+86 ⌄」这种文字控件，这里放开约束让它按内容自适应。
        prefixIconConstraints:
            prefixIcon == null
                ? null
                : const BoxConstraints(minWidth: 0, minHeight: 0),

        suffixIcon: suffixIcon,

        // ---------------------------------------------------------------------
        // 以下覆盖全局 inputDecorationTheme（实心浅灰、无边框）。
        //
        // 只在认证页覆盖而不是改全局：首页 / 账单那些页面是纯白底，
        // 而这里要的是"半透明填充 + 细描边"——填色一旦离开卡片
        // 就直接看不见了，反过来改全局则会污染那些页面。
        // ---------------------------------------------------------------------
        filled: true,

        // 蓝 6%：浅色底上要"有填充但不抢戏"，
        // 实心浅灰（surfaceSoft）压在冷调卡片上会发脏。
        fillColor: AppColors.coolMid.withValues(alpha: 0.06),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: _hairline(AppColors.glassEdge),

        // 静止态用极淡的深冷色描边。
        // 浅色底上不能用白色描边（等于没画），
        // 也不宜用中性灰（和整页冷调脱节）。
        enabledBorder: _hairline(AppColors.coolDeep.withValues(alpha: 0.10)),

        focusedBorder: _hairline(AppColors.coolMid, width: 1.4),

        // 报错态同时给描边和文字上色：只换描边的话，
        // 红色在细线上太轻，扫一眼看不出是哪一格错了。
        errorBorder: _hairline(AppColors.expense, width: 1.2),

        focusedErrorBorder: _hairline(AppColors.expense, width: 1.6),

        disabledBorder: _hairline(AppColors.coolDeep.withValues(alpha: 0.06)),
      ),
    );
  }

  /// 统一圆角的细描边。
  static OutlineInputBorder _hairline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
