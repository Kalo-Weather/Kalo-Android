import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../theme/app_theme.dart';

@Preview()
Widget previewHumidityCard() => const HumidityCard(humidity: 65.0, dewPoint: 12.0, dewPointUnit: 'C');

class HumidityCard extends StatelessWidget {
  final double humidity;
  final double? dewPoint;
  final String? dewPointUnit;

  const HumidityCard({super.key, required this.humidity, this.dewPoint, this.dewPointUnit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: _DropletPainter(fill: humidity / 100),
            size: const Size(60, 60),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${humidity.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: KaloColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (dewPoint != null)
          Text(
            'Dew: ${dewPoint!.toStringAsFixed(0)}°${dewPointUnit ?? ''}',
            style: const TextStyle(
              color: KaloColors.secondaryText,
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}

class _DropletPainter extends CustomPainter {
  final double fill;

  _DropletPainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    final r = math.min(size.width, size.height) / 2 - 4;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx + r, center.dy - r * 0.2, center.dx + r * 0.7, center.dy + r * 0.3)
      ..quadraticBezierTo(center.dx + r * 0.3, center.dy + r, center.dx, center.dy + r * 0.6)
      ..quadraticBezierTo(center.dx - r * 0.3, center.dy + r, center.dx - r * 0.7, center.dy + r * 0.3)
      ..quadraticBezierTo(center.dx - r, center.dy - r * 0.2, center.dx, center.dy - r)
      ..close();

    final bgPaint = Paint()
      ..color = KaloColors.frostBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, bgPaint);

    if (fill > 0) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF42A5F5).withValues(alpha: 0.8),
            const Color(0xFF42A5F5).withValues(alpha: 0.3),
          ],
        ).createShader(Rect.fromLTWH(0, size.height * (1 - fill), size.width, size.height * fill));
      canvas.save();
      canvas.clipPath(path);
      canvas.drawRect(Rect.fromLTWH(0, size.height * (1 - fill), size.width, size.height * fill), fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DropletPainter oldDelegate) => oldDelegate.fill != fill;
}
