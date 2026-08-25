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
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white10,
          highlightColor: Colors.white10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: KaloColors.secondaryText, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: KaloColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(child: content),
            ],
          ),
        ),
      ),
    );
  }
}
