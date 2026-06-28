import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class KaloColors {
  static Color amoledDark = const Color(0xFF000000);
  static Color frostWhite = const Color(0x1AFFFFFF);
  static Color frostBorder = const Color(0x26FFFFFF);
  static Color primaryText = const Color(0xFFFFFFFF);
  static Color secondaryText = const Color(0x99FFFFFF);
  static Color frostFill = const Color(0x1AFFFFFF);


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
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0x40000000),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KaloColors.frostBorder),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
