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
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1A2E),
        ),
        child: frameUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  frameUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'Radar unavailable',
                      style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
                    ),
                  ),
                ),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar, color: KaloColors.secondaryText, size: 28),
                    SizedBox(height: 4),
                    Text(
                      'Precipitation',
                      style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
                    ),
                    Text(
                      'Tap to view',
                      style: TextStyle(color: KaloColors.secondaryText, fontSize: 10),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
