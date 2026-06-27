import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../theme/app_theme.dart';


@Preview()
Widget previewWeatherCard() => WeatherCard(
  title: 'UV Index',
  icon: Icons.wb_sunny_outlined,
  content: Text('6', style: const TextStyle(color: Colors.white, fontSize: 24)),
);

enum CardSize { small, wide, large }

class WeatherCard extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData icon;
  final CardSize size;
  final VoidCallback? onTap;

  const WeatherCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.size = CardSize.small,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlass(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: KaloColors.secondaryText, size: 14),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: KaloColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(child: content),
          ],
        ),
      ),
    );
  }
}
