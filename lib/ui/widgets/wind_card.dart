import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/wind_data.dart';
import '../../theme/app_theme.dart';

@Preview()
Widget previewWindCompassCard() => WindCompassCard(wind: WindData(speed: 12, direction: 180, gust: 20));

class WindCompassCard extends StatelessWidget {
  final WindData wind;

  const WindCompassCard({super.key, required this.wind});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _CompassPainter(direction: wind.direction, speed: wind.speed),
            size: const Size(80, 80),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${wind.speed.toStringAsFixed(0)} km/h',
                style: TextStyle(
                  color: KaloColors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${wind.directionLabel} ${wind.direction.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: KaloColors.secondaryText,
                  fontSize: 13,
                ),
              ),
              if (wind.gust != null)
                Text(
                  'Gusts: ${wind.gust!.toStringAsFixed(0)} km/h',
                  style: TextStyle(
                    color: KaloColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double direction;
  final double speed;

  _CompassPainter({required this.direction, required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    final ringPaint = Paint()
      ..color = KaloColors.frostBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);

    final angle = (direction - 90) * math.pi / 180;
    final pointerPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.fill;
    final tip = center + Offset(radius * 0.7 * math.cos(angle), radius * 0.7 * math.sin(angle));
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(center.dx + 6 * math.cos(angle + 2.5), center.dy + 6 * math.sin(angle + 2.5))
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(center.dx + 6 * math.cos(angle - 2.5), center.dy + 6 * math.sin(angle - 2.5))
      ..close();
    canvas.drawPath(path, pointerPaint);

    canvas.drawCircle(center, 3, Paint()..color = KaloColors.secondaryText);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.direction != direction || oldDelegate.speed != speed;
}
