import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location_service.dart';

class WeatherAlert {
  final String event;
  final String headline;
  final String severity;
  final String urgency;
  final String? description;
  final String? instruction;
  final DateTime? expires;

  WeatherAlert({
    required this.event,
    required this.headline,
    required this.severity,
    required this.urgency,
    this.description,
    this.instruction,
    this.expires,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>? ?? {};
    return WeatherAlert(
      event: props['event'] as String? ?? 'Unknown Event',
      headline: props['headline'] as String? ?? props['event'] as String? ?? '',
      severity: props['severity'] as String? ?? 'Unknown',
      urgency: props['urgency'] as String? ?? 'Unknown',
      description: props['description'] as String?,
      instruction: props['instruction'] as String?,
      expires: props['expires'] != null ? DateTime.tryParse(props['expires'] as String) : null,
    );
  }
}

final weatherAlertsProvider = FutureProvider<List<WeatherAlert>>((ref) async {
  final pos = await ref.watch(currentPositionProvider.future);
  if (pos == null) return [];

  final countryCode = await ref.watch(currentCountryCodeProvider.future);
  if (countryCode != null && countryCode != 'US') return [];

  try {
    final uri = Uri.parse('https://api.weather.gov/alerts/active').replace(
      queryParameters: {
        'point': '${pos.latitude.toStringAsFixed(4)},${pos.longitude.toStringAsFixed(4)}',
      },
    );
    final res = await http.get(uri, headers: {
      'User-Agent': 'Kalo Weather App, contact ngbcoder@gmail.com',
      'Accept': 'application/geo+json',
    });
    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];
    return features
        .map((f) => WeatherAlert.fromJson(f as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});
