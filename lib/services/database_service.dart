import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_key.dart';
import '../models/weather_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => throw UnimplementedError());

final allLocationsProvider = FutureProvider<List<WeatherLocation>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllLocations();
});

class DatabaseService {
  final SharedPreferences prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DatabaseService(this.prefs);

  static const String _apiKeysKey = 'api_keys';
  static const String _locationsKey = 'weather_locations';
  static int _idCounter = 0;

  static Future<DatabaseService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('_id_counter');
    _idCounter = savedId ?? 0;
    return DatabaseService(prefs);
  }

  int _nextId() {
    _idCounter++;
    prefs.setInt('_id_counter', _idCounter);
    return _idCounter;
  }

  // API Key operations — stored in encrypted platform keychain
  Future<void> saveApiKey(String provider, String encryptedValue) async {
    final keys = await getAllApiKeys();
    final existingIndex = keys.indexWhere((k) => k.provider == provider);
    if (existingIndex >= 0) {
      keys[existingIndex] = ApiKey(
        id: keys[existingIndex].id,
        provider: provider,
        encryptedValue: encryptedValue,
      );
    } else {
      keys.add(ApiKey(
        id: _nextId(),
        provider: provider,
        encryptedValue: encryptedValue,
      ));
    }
    await _saveApiKeys(keys);
  }

  Future<ApiKey?> getApiKey(String provider) async {
    final keys = await getAllApiKeys();
    try {
      return keys.firstWhere((k) => k.provider == provider);
    } catch (_) {
      return null;
    }
  }

  Future<List<ApiKey>> getAllApiKeys() async {
    final json = await _secureStorage.read(key: _apiKeysKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => ApiKey.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveApiKeys(List<ApiKey> keys) async {
    final json = jsonEncode(keys.map((k) => k.toJson()).toList());
    await _secureStorage.write(key: _apiKeysKey, value: json);
  }

  // Location operations — stored in SharedPreferences (non-sensitive metadata)
  Future<void> deleteLocation(int locationId) async {
    final locations = await getAllLocations();
    locations.removeWhere((l) => l.id == locationId);
    await _saveLocations(locations);
  }

  Future<void> addLocation(String name, double lat, double lon) async {
    final locations = await getAllLocations();
    final order = locations.isEmpty ? 0 : locations.map((l) => l.order).reduce((a, b) => a > b ? a : b) + 1;
    locations.add(WeatherLocation(
      id: _nextId(),
      name: name,
      latitude: lat,
      longitude: lon,
      order: order,
    ));
    await _saveLocations(locations);
  }

  Future<List<WeatherLocation>> getAllLocations() async {
    final json = prefs.getString(_locationsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    final locations =
        list.map((e) => WeatherLocation.fromJson(e as Map<String, dynamic>)).toList();
    locations.sort((a, b) => a.order.compareTo(b.order));
    return locations;
  }

  Future<void> _saveLocations(List<WeatherLocation> locations) async {
    final json = jsonEncode(locations.map((l) => l.toJson()).toList());
    await prefs.setString(_locationsKey, json);
  }
}
