import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationParadigm {
  locationCarousel,
  stackView,
}

final navigationParadigmProvider = StateProvider<NavigationParadigm>((ref) => NavigationParadigm.locationCarousel);

final unitPreferenceProvider = StateProvider<String>((ref) => 'Celsius');

final timeFormatProvider = StateProvider<String>((ref) => '24h');
