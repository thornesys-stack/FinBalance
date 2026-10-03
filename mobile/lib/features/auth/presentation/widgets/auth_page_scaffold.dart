import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'auth_hero_header.dart';
import 'glass_surface.dart';

/// 认证页（登录 / 注册）的统一外框。
///
/// 版式：浅冷渐变 + 柔和色晕打底 → 深色标题 → 一张毛玻璃卡片承载表单。
///
/// 为什么渐变铺满整页、而不是只做一个色块标题栏：
///   1. 玻璃只对**背后有东西**的页面成立。卡片背后要是空的，
///      磨砂层就没得可磨，半透明按钮更是直接看不见；
///   2. 少一层容器 —— 标题栏那种「圆角色块 + 卡片负位移叠压」的做法
///      要多两个 BoxDecoration 和一个 Transform 才能对齐，
///      而铺满整页的渐变天然对齐，也没有叠压时的高度耦合
///      （标题换行导致色块变高，卡片就要跟着挪）。
class AuthPageScaffold extends StatelessWidget {
  final String title;

  final String subtitle;

  final Widget child;

  final bool showWordmark;

  const AuthPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backdropBase,

      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackdrop()),

          SafeArea(
            // bottom: false —— 底部安全区自己加，这样滚动内容能一直顶到屏幕边，
            // 而不是在刘海屏上被 SafeArea 提前裁掉一块底纹。
            bottom: false,

            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 28,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),

                    child: AuthHeroHeader(
                      title: title,
                      subtitle: subtitle,
                      showWordmark: showWordmark,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),

                    child: GlassSurface(
                      radius: 26,

                      // 卡片是页面上唯一一处「大块玻璃」，模糊开在这里最值：
                      // 卡片背后正好压着中间那团色晕，模糊之后卡内卡外
                      // 能明显看出「磨过 / 没磨过」的差别。
                      blur: 22,

                      fill: AppColors.glassCardFill,

                      borderColor: AppColors.glassCardBorder,

                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),

                      // 浅色底上的投影必须比深色底轻得多：
                      // 同一个 26% 的黑，压在浅色上会脏成一圈灰边。
                      shadows: [
                        BoxShadow(
                          color: AppColors.coolDeep.withValues(alpha: 0.10),

                          blurRadius: 30,

                          offset: const Offset(0, 14),
                        ),

                        BoxShadow(
                          color: AppColors.coolDeep.withValues(alpha: 0.04),

                          blurRadius: 6,

                          offset: const Offset(0, 2),
                        ),
                      ],

                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 整页底纹：浅冷渐变 + 三团柔和色晕，**没有任何纹理**。
///
/// 视觉重量全部交给渐变和卡片本身。之所以连底纹都省掉：
/// 点阵、线条这类图案会在卡片边缘形成「有 / 没有纹理」的硬分界，
/// 视线一落到那里就会被读成一条缝；柔光不会 —— 它只在卡片里
/// 留下一层浓淡变化，玻璃的厚度反而更容易读出来。
///
/// 三团都用 [Positioned] 的负偏移而不是 [Alignment]：
/// 色晕比屏幕还大，Alignment 会把「右上角」算成屏幕中线附近
/// （对齐的是子控件的边，不是圆心），负偏移才是字面意思上的贴角。
class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // RepaintBoundary：三团 300px+ 的径向渐变是整页最重的一块绘制，
      // 但它们永远不参与交互。单独缓存成一层之后，
      // 表单里任何一次状态刷新都不会带着它们重画。
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.authBackdropGradient,
        ),

        child: const Stack(
          children: [
            // 1) 中间偏下：正压在卡片下方，给玻璃一点可透的浓淡。
            //    没有它，卡片透上来的就是一片死白，磨砂感立不住。
            Positioned(
              top: 170,
              left: -20,
              child: _GlowBlob(
                size: 420,
                color: AppColors.coolMid,
                alpha: 0.14,
              ),
            ),

            // 2) 右上角冷青：整页最亮的一点，把视线往上带到标题
            Positioned(
              top: -110,
              right: -60,
              child: _GlowBlob(
                size: 340,
                color: AppColors.coolCyan,
                alpha: 0.30,
              ),
            ),

            // 3) 左下角冷蓝：与右上角对角呼应，避免整页往一个方向偏色
            Positioned(
              bottom: -90,
              left: -90,
              child: _GlowBlob(
                size: 360,
                color: AppColors.coolBright,
                alpha: 0.22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一团柔光。
///
/// 抽成组件而不是把 SizedBox + DecoratedBox 抄三遍：三团的差别只有
/// 大小、颜色、浓度三个数，抄三遍之后想统一改衰减曲线（比如 [stops]）
/// 就得改三处。
class _GlowBlob extends StatelessWidget {
  /// 方框边长，圆形色晕的直径即此值。
  final double size;

  final Color color;

  /// 圆心处的最大不透明度。
  final double alpha;

  const _GlowBlob({
    required this.size,
    required this.color,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(size, size),

      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),

              // 中间插一档：两档线性衰减的大面积柔光在 8bit 色深下
              // 会出现可见的同心色阶（banding）。把衰减拉成曲线，
              // 边缘才真正「化」得开。
              color.withValues(alpha: alpha * 0.34),

              color.withValues(alpha: 0),
            ],

            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}
