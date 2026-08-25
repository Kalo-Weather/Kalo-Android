import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class KaloColors {
  static Color amoledDark = const Color(0xFF000000);
  static Color frostWhite = const Color(0x1AFFFFFF);
  static Color frostBorder = const Color(0x33FFFFFF);
  static Color primaryText = const Color(0xFFFFFFFF);
  static Color secondaryText = const Color(0x99FFFFFF);
  static Color frostFill = const Color(0x1AFFFFFF);
  static Color accentOrange = const Color(0xFFFF6B35);
  static Color accentBlue = const Color(0xFF4A90D9);

  static BoxDecoration glassCard({double radius = 24}) => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
    boxShadow: const [
      BoxShadow(
        color: Color(0x20000000),
        blurRadius: 20,
        spreadRadius: 0,
        offset: Offset(0, 4),
      ),
    ],
  );
}

class SkyGradients {
  static const LinearGradient clearDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A90D9), Color(0xFF1A3A6B)],
  );

  static const LinearGradient stormy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2C2C2C), Color(0xFF1A1A2E)],
  );

  static const LinearGradient clearNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E)],
  );

  static const LinearGradient goldenHour = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFCC5500), Color(0xFF6B2FA0)],
  );

  static const LinearGradient cloudy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6B7B8D), Color(0xFF3A4A5C)],
  );

  static const LinearGradient snowy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB0C4DE), Color(0xFF778899)],
  );

  static LinearGradient forCondition(String condition, bool isDay) {
    if (condition == 'stormy' || condition == 'rainy') {
      return stormy;
    }
    if (condition == 'snowy') {
      return snowy;
    }
    if (!isDay) {
      return clearNight;
    }
    if (condition == 'cloudy') {
      return cloudy;
    }
    if (condition == 'foggy') {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8B8B8B), Color(0xFF5A5A5A)],
      );
    }
    return clearDay;
  }
}

@Preview()
Widget previewFrostedGlass() => const FrostedGlass(
  padding: EdgeInsets.all(16),
  child: Text('Preview', style: TextStyle(color: Colors.white)),
);

class FrostedGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const FrostedGlass({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: KaloColors.glassCard(),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
