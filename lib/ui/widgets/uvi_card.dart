import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/uv_index.dart';
import '../../theme/app_theme.dart';

@Preview()
Widget previewUVICard() => UVICard(uvIndex: UVIndex(value: 2.2, label: 'Testing', protectionTip: 'Wear sunscreen'));

class UVICard extends StatelessWidget {
  final UVIndex uvIndex;

  const UVICard({super.key, required this.uvIndex});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerY = constraints.maxHeight * 0.3;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _UVSemiCirclePainter(
                  progress: uvIndex.progress,
                  centerY: centerY,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${uvIndex.value.toInt()}',
                    style: TextStyle(
                      color: KaloColors.primaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    uvIndex.label,
                    style: TextStyle(
                      color: _colorForLabel(uvIndex.label),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    uvIndex.protectionTip,
                    style: TextStyle(
                      color: KaloColors.secondaryText,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _colorForLabel(String label) {
    switch (label) {
      case 'Low':
        return Colors.green;
      case 'Moderate':
        return Colors.yellow;
      case 'High':
        return Colors.orange;
      case 'Very High':
        return Colors.red;
      case 'Extreme':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _UVSemiCirclePainter extends CustomPainter {
  final double progress;
  final double centerY;

  _UVSemiCirclePainter({required this.progress, required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || !centerY.isFinite) return;
    final center = Offset(size.width / 2, centerY);
    final raw = math.min(size.width, centerY * 2) / 2 - 10;
    final radius = raw.isFinite ? math.max(1.0, raw) : 1.0;

    final bgPaint = Paint()
      ..color = KaloColors.frostWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, -math.pi, false, bgPaint);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red, Colors.purple],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, -math.pi * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _UVSemiCirclePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.centerY != centerY;
}
