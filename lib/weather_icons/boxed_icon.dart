import 'package:flutter/material.dart';

class BoxedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const BoxedIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final iconSize = size ?? theme.size!;
    final iconOpacity = theme.opacity;
    var iconColor = color ?? theme.color;
    if (iconColor != null && iconOpacity != null && iconOpacity != 1.0) {
      iconColor = iconColor.withValues(alpha: iconColor.a * iconOpacity);
    }

    return SizedBox(
      width: iconSize * 1.5,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              inherit: false,
              color: iconColor,
              fontSize: iconSize,
              fontFamily: icon.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
