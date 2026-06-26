import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/weather_condition.dart';

@Preview()
Widget previewWeatherIllustration() => const WeatherIllustration(condition: WeatherCondition.clearSky, isDay: true);

class WeatherIllustration extends StatelessWidget {
  final WeatherCondition condition;
  final bool isDay;
  final double size;

  const WeatherIllustration({
    super.key,
    required this.condition,
    this.isDay = true,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WeatherPainter(condition: condition, isDay: isDay),
        size: Size(size, size),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final WeatherCondition condition;
  final bool isDay;

  _WeatherPainter({required this.condition, required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    switch (condition) {
      case WeatherCondition.clearSky:
        _drawClearSky(canvas, center, r);
      case WeatherCondition.rainy:
        _drawRainy(canvas, center, r);
      case WeatherCondition.snowy:
        _drawSnowy(canvas, center, r);
      case WeatherCondition.foggy:
        _drawFoggy(canvas, center, r);
      case WeatherCondition.cloudy:
        _drawCloudy(canvas, center, r);
      case WeatherCondition.stormy:
        _drawStormy(canvas, center, r);
    }
  }

  void _drawClearSky(Canvas canvas, Offset center, double r) {
    if (isDay) {
      final sunPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(center, r * 0.35, sunPaint);
      for (var i = 0; i < 8; i++) {
        final angle = i * 3.14159 / 4;
        final dx = r * 0.55 * _ringOffset(angle);
        final dy = r * 0.55 * _ringOffset2(angle);
        final idx = r * 0.4 * _ringOffset(angle);
        final idy = r * 0.4 * _ringOffset2(angle);
        canvas.drawLine(
          center + Offset(idx, idy),
          center + Offset(dx, dy),
          Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.5)..strokeWidth = 2,
        );
      }
    } else {
      final moonPaint = Paint()..color = const Color(0xFFC0C0C0);
      canvas.drawCircle(center, r * 0.3, moonPaint);
      canvas.drawCircle(center + Offset(r * 0.12, -r * 0.1), r * 0.25,
          Paint()..color = const Color(0xFF0D0D1A));
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (var i = 0; i < 8; i++) {
        final angle = i * 3.14159 / 4;
        final dist = r * (0.5 + (i % 3) * 0.1);
        canvas.drawCircle(
          center + Offset(dist * _ringOffset(angle), dist * _ringOffset2(angle)),
          1.5,
          starPaint,
        );
      }
    }
  }

  void _drawRainy(Canvas canvas, Offset center, double r) {
    final cloudPaint = Paint()..color = isDay ? const Color(0xFFFFFFFF) : const Color(0xFF1A237E);
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 1.2, height: r * 0.5), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-r * 0.2, -r * 0.1), width: r * 0.6, height: r * 0.35), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(r * 0.2, -r * 0.1), width: r * 0.6, height: r * 0.35), cloudPaint);
    final rainPaint = Paint()..color = const Color(0xFF42A5F5)..strokeWidth = 1.5;
    for (var i = -2; i <= 2; i++) {
      final x = center.dx + i * r * 0.1;
      canvas.drawLine(Offset(x, center.dy + r * 0.15), Offset(x - 4, center.dy + r * 0.35), rainPaint);
    }
    if (!isDay) {
      _drawLightning(canvas, center, r);
    }
  }

  void _drawSnowy(Canvas canvas, Offset center, double r) {
    final cloudPaint = Paint()..color = isDay ? const Color(0xFFFFFFFF) : const Color(0xFF37474F);
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 1.2, height: r * 0.5), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-r * 0.2, -r * 0.1), width: r * 0.6, height: r * 0.35), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(r * 0.2, -r * 0.1), width: r * 0.6, height: r * 0.35), cloudPaint);
    final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    for (var i = -2; i <= 2; i++) {
      canvas.drawCircle(Offset(center.dx + i * r * 0.12, center.dy + r * 0.2 + (i.abs() % 3) * 4), 2.5, snowPaint);
    }
    if (!isDay) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
      for (var i = 0; i < 4; i++) {
        final angle = i * 3.14159 / 2;
        canvas.drawCircle(
          center + Offset(r * 0.4 * _ringOffset(angle), r * 0.4 * _ringOffset2(angle)),
          1.5,
          starPaint,
        );
      }
    }
  }

  void _drawFoggy(Canvas canvas, Offset center, double r) {
    final bandPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    for (var i = -1; i <= 1; i++) {
      final y = center.dy + i * r * 0.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx, y), width: r * 1.4, height: 6),
          const Radius.circular(3),
        ),
        bandPaint,
      );
    }
    if (!isDay) {
      final moonPaint = Paint()..color = const Color(0xFFC0C0C0).withValues(alpha: 0.4);
      canvas.drawCircle(center + Offset(r * 0.15, -r * 0.15), r * 0.15, moonPaint);
    }
  }

  void _drawCloudy(Canvas canvas, Offset center, double r) {
    final cloudPaint = Paint()..color = isDay ? const Color(0xFFFFFFFF).withValues(alpha: 0.8) : const Color(0xFF546E7A);
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 1.3, height: r * 0.55), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-r * 0.25, -r * 0.12), width: r * 0.65, height: r * 0.4), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(r * 0.25, -r * 0.08), width: r * 0.55, height: r * 0.35), cloudPaint);
  }

  void _drawStormy(Canvas canvas, Offset center, double r) {
    _drawRainy(canvas, center, r);
    _drawLightning(canvas, center, r);
  }

  void _drawLightning(Canvas canvas, Offset center, double r) {
    final boltPaint = Paint()..color = const Color(0xFFFFD700)..strokeWidth = 2.5;
    final path = Path()
      ..moveTo(center.dx + r * 0.05, center.dy - r * 0.1)
      ..lineTo(center.dx - r * 0.05, center.dy + r * 0.05)
      ..lineTo(center.dx + r * 0.02, center.dy + r * 0.05)
      ..lineTo(center.dx - r * 0.08, center.dy + r * 0.25);
    canvas.drawPath(path, boltPaint);
  }

  double _ringOffset(double angle) => angle;
  double _ringOffset2(double angle) => angle;

  @override
  bool shouldRepaint(covariant _WeatherPainter oldDelegate) =>
      oldDelegate.condition != condition || oldDelegate.isDay != isDay;
}
