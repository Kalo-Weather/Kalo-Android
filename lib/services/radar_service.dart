import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final radarFrameProvider = FutureProvider<String?>((ref) async {
  final res = await http.get(Uri.parse('https://api.rainviewer.com/public/weather-maps.json'));
  if (res.statusCode != 200) return null;
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  final host = data['host'] as String;
  final past = data['radar']['past'] as List<dynamic>;
  if (past.isEmpty) return null;
  final latest = past.last as Map<String, dynamic>;
  return '$host${latest['path']}/256/{z}/{x}/{y}/2/1_1.png';
});
