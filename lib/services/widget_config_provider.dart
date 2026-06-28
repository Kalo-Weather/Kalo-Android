import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/widget_config.dart';

const _prefsKey = 'widget_editor_config';

final widgetConfigProvider = StateNotifierProvider<WidgetConfigNotifier, WidgetConfig>((ref) {
  return WidgetConfigNotifier();
});

class WidgetConfigNotifier extends StateNotifier<WidgetConfig> {
  WidgetConfigNotifier() : super(WidgetConfig.defaults()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = WidgetConfig.fromJson(json);
      }
    } catch (e) {
      debugPrint('WidgetConfigNotifier: failed to load config: $e');
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('WidgetConfigNotifier: failed to save config: $e');
    }
  }

  void updateBlocks(WidgetSize size, List<WidgetBlockType> blocks) {
    final config = WidgetSizeConfig(size: size, blocks: blocks);
    state = state.withUpdated(size, config);
  }

  Future<void> resetToDefault() async {
    state = WidgetConfig.defaults();
    await save();
  }
}
