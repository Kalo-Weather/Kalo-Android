import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class KaloColors {
  static const Color amoledDark = Color(0xFF000000);
  static const Color frostWhite = Color(0x1AFFFFFF);
  static const Color frostBorder = Color(0x26FFFFFF);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0x99FFFFFF);
  static const Color frostFill = Color(0x1AFFFFFF);
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

  static LinearGradient forCondition(String condition, bool isDay) {
    if (condition == 'stormy' || condition == 'rainy') {
      return stormy;
    }
    if (!isDay) {
      return clearNight;
    }
    if (condition == 'foggy') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF8B8B8B), const Color(0xFF5A5A5A)],
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
    return GlassCard(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      shape: const LiquidRoundedSuperellipse(borderRadius: 20),
      useOwnLayer: true,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
