import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../theme/app_theme.dart';

@Preview()
Widget previewRadarCard() => const RadarCard();

class RadarCard extends StatelessWidget {
  final String? frameUrl;
  final VoidCallback? onTap;

  const RadarCard({super.key, this.frameUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: frameUrl != null ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1A2E),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar, color: KaloColors.secondaryText, size: 28),
              const SizedBox(height: 4),
              Text(
                'Radar',
                style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
              ),
              Text(
                frameUrl != null ? 'Tap to view' : 'Unavailable',
                style: TextStyle(
                  color: frameUrl != null ? KaloColors.primaryText : KaloColors.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
