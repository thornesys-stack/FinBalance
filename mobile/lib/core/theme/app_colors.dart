import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();
  // Brand
  static const Color primary = Color(0xFF3157D5);

  static const Color primaryLight = Color(0xFFE8EDFF);

  static const Color primaryDark = Color(0xFF2444B2);
  // Background
  static const Color background = Color(0xFFF6F8FC);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color surfaceSoft = Color(0xFFF1F3F7);
  // Text
  static const Color textPrimary = Color(0xFF172033);

  static const Color textSecondary = Color(0xFF697386);

  static const Color textTertiary = Color(0xFF9AA3B2);
  // Financial
  static const Color income = Color(0xFF159A70);

  static const Color incomeSoft = Color(0xFFE8F7F1);

  static const Color expense = Color(0xFFE05B63);

  static const Color expenseSoft = Color(0xFFFCEBEC);

  static const Color warning = Color(0xFFE5A227);

  static const Color warningSoft = Color(0xFFFFF5DD);
  // Border
  static const Color border = Color(0xFFE7EAF0);

  static const Color divider = Color(0xFFEEF0F4);
  // Special
  static const Color ai = Color(0xFF7457D5);

  static const Color aiSoft = Color(0xFFF0ECFF);

  // ---------------------------------------------------------------------------
  // 冷色渐变体系（认证页专用）
  //
  // 全部落在冷色区间：深靛蓝 → 品牌蓝 → 冷青。为什么是三档而不是两档 ——
  // 两档渐变在斜向铺开时中段会明显发灰，插一档亮青才能把「冷」的观感压住。
  //
  // 只给认证页用：[AppColors.primary] 那套是 App 全局主色，
  // 改它会连带影响首页 / 账户 / 账单等已完成的页面。
  // ---------------------------------------------------------------------------
  static const Color coolDeep = Color(0xFF142B63);

  static const Color coolMid = Color(0xFF2153C6);

  static const Color coolBright = Color(0xFF3E9BDD);

  static const Color coolCyan = Color(0xFF5FD0E8);

  /// 认证页整页底色：浅冷调，斜向铺满。
  ///
  /// 三档都压在 90% 以上亮度，深色系那套只留给文字和按钮 ——
  /// 底色一深，卡片的毛玻璃就没有可透的空间，整页也会显沉。
  static const LinearGradient authBackdropGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F0FF), Color(0xFFF8FBFF), Color(0xFFE6F5FC)],
    stops: [0.0, 0.48, 1.0],
  );

  /// 渐变之外兜底的底色（窄机型上安全区外的边缘用它）。
  static const Color backdropBase = Color(0xFFEDF3FF);

  /// 主按钮的填充：冷色渐变，但只有 85% 不透明。
  ///
  /// 剩下那 15% 是玻璃的关键 —— 纯不透明色块是「塑料」，
  /// 留一点透才让底下的卡片和光斑渗上来。
  static const LinearGradient authPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xD92153C6), Color(0xD93E9BDD)],
  );

  /// 毛玻璃卡片：白 70%。
  ///
  /// 这个值取决于底色 —— 底色是浅色时，透出来的仍然是浅色，
  /// 深色正文的对比度不会掉（白 70% 压在本页底色上 ≈ #FAFCFF，
  /// 次要文字 #697386 仍有 4.7:1）。底色一旦改深，这个值必须跟着往上调。
  static const Color glassCardFill = Color(0xB3FFFFFF);

  static const Color glassCardBorder = Color(0xBFD5E4FC);

  /// 玻璃控件在**浅色底**上的描边。
  static const Color glassEdge = Color(0x1F142B63);

  /// 玻璃控件贴在**彩色填充**上时的高光描边。
  static const Color glassHighlight = Color(0xF2FFFFFF);

  /// 玻璃控件的半透明白填充（用于压在彩色 / 渐变上的部件）。
  static const Color glassFill = Color(0x8FFFFFFF);
}
