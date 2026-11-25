import 'package:flutter/material.dart';
import 'app_theme.dart';

// Ícono de gorra dibujado con código.
class CapIcon extends StatelessWidget {
  final double size;
  final Color crownColor;

  const CapIcon({
    super.key,
    this.size = 80,
    this.crownColor = AppColors.red,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CapPainter(crownColor)),
    );
  }
}

class _CapPainter extends CustomPainter {
  final Color crownColor;
  _CapPainter(this.crownColor);

  Paint _paint(Color c) => Paint()..color = c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const darkRed = AppColors.darkRed;

    // Visera
    final brim = Path()
      ..moveTo(w * 0.55, h * 0.64)
      ..quadraticBezierTo(w * 0.97, h * 0.60, w * 0.99, h * 0.76)
      ..quadraticBezierTo(w * 0.72, h * 0.82, w * 0.50, h * 0.74)
      ..close();
    canvas.drawPath(brim, _paint(darkRed));

    // Copa (la parte redonda)
    final crown = Path()
      ..moveTo(w * 0.10, h * 0.70)
      ..cubicTo(w * 0.10, h * 0.12, w * 0.84, h * 0.12, w * 0.84, h * 0.70)
      ..close();
    canvas.drawPath(crown, _paint(crownColor));

    // Costuras
    final seam = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.47, h * 0.30)
        ..quadraticBezierTo(w * 0.36, h * 0.46, w * 0.38, h * 0.64),
      seam,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.47, h * 0.30)
        ..quadraticBezierTo(w * 0.62, h * 0.46, w * 0.62, h * 0.64),
      seam,
    );

    // Banda inferior
    final band = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.08, h * 0.64, w * 0.86, h * 0.74),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(band, _paint(Colors.white));

    // Botón de arriba
    canvas.drawCircle(Offset(w * 0.47, h * 0.285), w * 0.04, _paint(darkRed));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
