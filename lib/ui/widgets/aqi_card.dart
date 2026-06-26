import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/air_quality.dart';
import '../../theme/app_theme.dart';

@Preview()
Widget previewAQICard() => AQICard(airQuality: AirQuality(index: 85, dominantPollutant: 'PM2.5'));

class AQICard extends StatelessWidget {
  final AirQuality airQuality;

  const AQICard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${airQuality.index.toInt()}',
          style: const TextStyle(
            color: KaloColors.primaryText,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          airQuality.label,
          style: TextStyle(
            color: _colorForAQI(airQuality.index),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red, Colors.deepPurple],
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: airQuality.progress,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          airQuality.dominantPollutant,
          style: const TextStyle(
            color: KaloColors.secondaryText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _colorForAQI(double index) {
    if (index <= 50) return Colors.green;
    if (index <= 100) return Colors.yellow;
    if (index <= 150) return Colors.orange;
    if (index <= 200) return Colors.red;
    if (index <= 300) return Colors.purple;
    return Colors.brown;
  }
}
