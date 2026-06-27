import 'package:flutter/material.dart';

class WeatherIcons {
  WeatherIcons._();

  static const IconData day_sunny = IconData(0xf00d, fontFamily: _fontFamily);
  static const IconData cloudy = IconData(0xf013, fontFamily: _fontFamily);
  static const IconData rain = IconData(0xf019, fontFamily: _fontFamily);
  static const IconData snow = IconData(0xf01b, fontFamily: _fontFamily);
  static const IconData showers = IconData(0xf01a, fontFamily: _fontFamily);
  static const IconData thunderstorm = IconData(0xf01e, fontFamily: _fontFamily);
  static const IconData night_clear = IconData(0xf02e, fontFamily: _fontFamily);
  static const IconData fog = IconData(0xf014, fontFamily: _fontFamily);

  static const String _fontFamily = 'WeatherIcons';
}
