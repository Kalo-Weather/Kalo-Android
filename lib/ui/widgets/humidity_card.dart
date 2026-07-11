import 'dart:math' as math;
import 'package:flutter/material.dart';

class SymmetricalRaindropCard extends StatelessWidget {
  final double humidity; // Value between 0.0 and 100.0
  final double? dewPoint;
  final String? dewPointUnit;

  const SymmetricalRaindropCard({
    super.key,
    required this.humidity,
    this.dewPoint,
    this.dewPointUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          painter: _RaindropPainter(fill: humidity / 100),
          size: const Size(60, 60), // Adapts perfectly to sizing constraints
        ),
        const SizedBox(height: 8),
        Text(
          '${humidity.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Color(0xFFE2E8F0), // Slate-200
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (dewPoint != null) ...[
          const SizedBox(height: 2),
          Text(
            'Dew: ${dewPoint!.toStringAsFixed(0)}°${dewPointUnit ?? "C"}',
            style: const TextStyle(
              color: Color(0xFF94A3B8), // Slate-400
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _RaindropPainter extends CustomPainter {
  final double fill;

  _RaindropPainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final path = Path();

    // 1. Establish the peak starting coordinate
    path.moveTo(w * 0.5, h * 0.1);

    // 2. Plot exact cubic spline to right bottom hip
    path.cubicTo(
      w * 0.5, h * (0.1 + 0.170),      // Dynamic tension
      w * (0.5 + 0.370), h * 0.55,    // Right hip pull
      w * (0.5 + 0.240), h * 0.75, // Bottom shoulder base
    );

    // 3. Round perfectly across the base plate
    path.cubicTo(
      w * (0.5 + 0.240 * 0.5), h * 0.95, // Rounding handles
      w * (0.5 - 0.240 * 0.5), h * 0.95,
      w * (0.5 - 0.240), h * 0.75,
    );

    // 4. Return to peak using matching symmetry curves
    path.cubicTo(
      w * (0.5 - 0.370), h * 0.55,
      w * 0.5, h * (0.1 + 0.170),
      w * 0.5, h * 0.1,
    );

    path.close();

    // Paint the boundary backdrop outline
    final strokePaint = Paint()
      ..color = const Color(0x33FFFFFF) // Subtle frosted border outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, strokePaint);

    // Crop interior space and fill up to dynamic height scale
    if (fill > 0.0) {
      final fullRect = Rect.fromLTWH(0, 0, w, h);
      final fillHeight = h * fill;
      final fillRect = Rect.fromLTWH(0, h * (1.0 - fill), w, fillHeight);

      // Multi-version Flutter color safe representation
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF42A5F5), // Primary (Liquid base)
            const Color(0xFF90CAF9), // Secondary (Liquid top)
          ],
        ).createShader(fullRect);

      canvas.save();
      canvas.clipPath(path);
      canvas.drawRect(fillRect, fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RaindropPainter oldDelegate) =>
      oldDelegate.fill != fill;
}