import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_key.dart';
import 'database_service.dart';

final apiKeysProvider = FutureProvider<List<ApiKey>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllApiKeys();
});

final weatherApiKeyProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final key = await db.getApiKey('openweathermap');
  return key?.encryptedValue;
});

final aqiApiKeyProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final key = await db.getApiKey('waqi');
  return key?.encryptedValue;
});
