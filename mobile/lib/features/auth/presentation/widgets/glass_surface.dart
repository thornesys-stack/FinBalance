import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 玻璃面板 —— 认证页所有「有颜色 / 有体积」的容器都从这里出来。
///
/// 三件事叠在一起才叫玻璃，少一件都会退化成一块半透明的塑料板：
///   1. **半透明填充**：底下的底纹和柔光能渗上来；
///   2. **背景模糊**（[blur] > 0）：把背后的底纹揉开，边缘才不会「透得发脏」；
///   3. **描边 + 顶部反光**（[sheen]）：玻璃的厚度感全靠这一层。
///
/// 关于 [blur] 的取舍：模糊会多一次离屏合成，只在两个地方开 ——
/// 卡片本身、以及品牌标。它们背后是**有点阵底纹**的，模糊之后卡片里外
/// 能明显看出「被磨过」和「没被磨过」的区别。
/// 按钮贴在已经模糊过的卡片上，再叠一层模糊只是白烧一次合成。
class GlassSurface extends StatelessWidget {
  final Widget child;

  final double radius;

  /// 背景模糊半径，0 = 关闭。
  final double blur;

  /// 纯色填充。[gradient] 非空时忽略。
  final Color? fill;

  /// 渐变填充（与 [fill] 互斥）。
  final Gradient? gradient;

  /// 描边色。浅色底用 [AppColors.glassEdge]，压在彩色填充上用 [AppColors.glassHighlight]。
  final Color borderColor;

  final List<BoxShadow>? shadows;

  final EdgeInsetsGeometry? padding;

  /// 顶部白色反光。
  final bool sheen;

  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 0,
    this.fill,
    this.gradient,
    this.borderColor = AppColors.glassEdge,
    this.shadows,
    this.padding,
    this.sheen = false,
  });

  @override
  Widget build(BuildContext context) {
    // 内边距交给内层：外层只负责底色、描边和反光。
    // 若把 padding 写在外层，反光的 Positioned.fill 会跟着一起缩进去，
    // 玻璃表面的四边就会缺一圈高光。
    final inner = Container(padding: padding, child: child);

    Widget panel = Container(
      decoration: BoxDecoration(
        // BoxDecoration 不允许 color 与 gradient 同时非空，这里显式二选一。
        color: gradient == null ? (fill ?? AppColors.glassFill) : null,

        gradient: gradient,

        borderRadius: BorderRadius.circular(radius),

        border: Border.all(color: borderColor),
      ),

      child: sheen ? _withSheen(inner) : inner,
    );

    if (blur > 0) {
      panel = ClipRRect(
        borderRadius: BorderRadius.circular(radius),

        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),

          child: panel,
        ),
      );
    }

    final shadowList = shadows;

    if (shadowList == null || shadowList.isEmpty) {
      return panel;
    }

    // 阴影必须画在 ClipRRect **外面**：裁切会连着阴影一起裁掉，
    // 卡片看起来就会像贴纸一样浮不起来。
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadowList,
      ),

      child: panel,
    );
  }

  /// 顶部斜向的白光，模拟光源从左上来。
  Widget _withSheen(Widget content) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),

                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,

                  colors: [
                    Colors.white.withValues(alpha: 0.34),
                    Colors.white.withValues(alpha: 0),
                  ],

                  // 反光只铺上半段。铺满会整体泛白，
                  // 按钮的文字对比度反而被拉低。
                  stops: const [0.0, 0.55],
                ),
              ),
            ),
          ),
        ),

        content,
      ],
    );
  }
}

/// 玻璃按钮的外壳。
///
/// 为什么不用 [FilledButton] / [OutlinedButton]：
/// 它们的填充是实色的，拿不到「渐变 + 顶部反光 + 高光描边」这一组效果；
/// 硬套的话要给每个按钮写一堆 `styleFrom`，比直接画一个还长。
///
/// 交互（水波纹、禁用态）由内部的 [InkWell] 承担，不自己实现 ——
/// 手势与无障碍语义交给框架，行为才和系统一致。
class GlassButton extends StatelessWidget {
  final Widget child;

  /// null = 禁用。
  final VoidCallback? onPressed;

  final double height;

  final double radius;

  /// 主按钮传冷色渐变；null 时用 [fill] 的纯色玻璃。
  final Gradient? gradient;

  final Color? fill;

  final Color borderColor;

  final List<BoxShadow>? shadows;

  final EdgeInsetsGeometry? padding;

  final bool sheen;

  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.height = 52,
    this.radius = 15,
    this.gradient,
    this.fill,
    this.borderColor = AppColors.glassEdge,
    this.shadows,
    this.padding,
    this.sheen = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Opacity(
      // 禁用态用整体降透明度，而不是换一套灰色配色：
      // 玻璃按钮换灰会把「半透明」这个特征抹掉，用户反而看不出是同一颗按钮。
      opacity: enabled ? 1 : 0.48,

      child: GlassSurface(
        radius: radius,

        // 卡片已经是磨砂的了，见 [GlassSurface.blur] 的说明。
        blur: 0,

        fill: fill,

        gradient: gradient,

        borderColor: borderColor,

        shadows: shadows,

        sheen: sheen,

        child: Material(
          type: MaterialType.transparency,

          child: InkWell(
            onTap: onPressed,

            borderRadius: BorderRadius.circular(radius),

            child: Container(
              height: height,

              alignment: Alignment.center,

              padding: padding,

              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
