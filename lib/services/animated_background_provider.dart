import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final animatedBackgroundProvider = StateNotifierProvider<AnimatedBackgroundNotifier, bool>((ref) {
  return AnimatedBackgroundNotifier();
});

class AnimatedBackgroundNotifier extends StateNotifier<bool> {
  AnimatedBackgroundNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('animated_background') ?? false;
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animated_background', value);
  }
}
