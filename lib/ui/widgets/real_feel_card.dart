import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RealFeelCard extends StatelessWidget {
  final double feelsLike;
  final double actualTemp;
  final String unit;

  const RealFeelCard({
    super.key,
    required this.feelsLike,
    required this.actualTemp,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final diff = (feelsLike - actualTemp).abs();
    final isWarmer = feelsLike > actualTemp;
    final clampedDiff = diff.clamp(0.0, 15.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: _ThermometerPainter(
              feelsLike: feelsLike,
              actualTemp: actualTemp,
              diff: clampedDiff,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${feelsLike.toStringAsFixed(0)}°$unit',
          style: TextStyle(
            color: KaloColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (diff >= 2)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${isWarmer ? '+' : '-'}${diff.toStringAsFixed(0)}°',
              style: TextStyle(
                color: KaloColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _ThermometerPainter extends CustomPainter {
  final double feelsLike;
  final double actualTemp;
  final double diff;

  _ThermometerPainter({
    required this.feelsLike,
    required this.actualTemp,
    required this.diff,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final radius = math.min(size.width, size.height) / 2 - 4;

    final bgPaint = Paint()
      ..color = KaloColors.frostBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final innerRadius = radius - 4;
    final fillAngle = (diff / 15) * math.pi;
    final isWarmer = feelsLike > actualTemp;

    canvas.drawCircle(center, radius, bgPaint);

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (isWarmer) {
      fillPaint
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [Colors.orange.shade300, Colors.red.shade400],
        ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    } else {
      fillPaint
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [Colors.lightBlue.shade300, Colors.blue.shade400],
        ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -math.pi / 2,
      isWarmer ? fillAngle : -fillAngle,
      false,
      fillPaint,
    );

    final iconPaint = Paint()..color = isWarmer ? Colors.orange.shade300 : Colors.lightBlue.shade300;
    canvas.drawCircle(center, 4, iconPaint);
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter oldDelegate) =>
      oldDelegate.feelsLike != feelsLike || oldDelegate.actualTemp != actualTemp;
}
