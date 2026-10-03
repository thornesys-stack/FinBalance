import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Google 官方的四色标志。
///
/// 为什么用 CustomPainter 自己画，而不是放一张 SVG/PNG：
///   - 项目没接 flutter_svg，为了一个 18px 的图标引一个渲染库不划算；
///   - PNG 在多倍屏上要么糊、要么得准备 4 套；
///   - 这里只有四条弧加一根横杠，用代码画反而更简单也更锐利。
///
/// 四色取自 Google 的品牌规范值，不要随手改：
/// 换掉任意一个颜色，这个图形就不再是"Google G"了。
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: const _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const Color _blue = Color(0xFF4285F4);

  static const Color _green = Color(0xFF34A853);

  static const Color _yellow = Color(0xFFFBBC05);

  static const Color _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;

    if (side <= 0) {
      return;
    }

    final stroke = side * 0.22;

    final radius = (side - stroke) / 2;

    final center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final arc =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          // 平切口而不是圆头：官方标志的每一段都是径向切断的。
          ..strokeCap = StrokeCap.butt;

    // 角度约定与 Canvas 一致：0° 指向右侧、顺时针为正。
    // 四段之间的空隙对应官方标志里那道白色分隔线。
    arc.color = _yellow;
    canvas.drawArc(rect, _deg(140), _deg(76), false, arc);

    arc.color = _green;
    canvas.drawArc(rect, _deg(48), _deg(80), false, arc);

    arc.color = _blue;
    canvas.drawArc(rect, _deg(-38), _deg(74), false, arc);

    arc.color = _red;
    canvas.drawArc(rect, _deg(208), _deg(86), false, arc);

    // 那根横杠：少了它，这只是一个四色圆环，认不出是 Google。
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - side * 0.02,
        center.dy - stroke / 2,
        radius + stroke / 2 + side * 0.02,
        stroke,
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = _blue,
    );
  }

  static double _deg(double degrees) => degrees * math.pi / 180;

  // 纯静态图形，参数不变就永远是同一张画。
  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
