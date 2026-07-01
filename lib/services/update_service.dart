import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class AppUpdate {
  final String version;
  final String downloadUrl;
  final String? releaseNotes;
  final int? fileSize;

  AppUpdate({
    required this.version,
    required this.downloadUrl,
    this.releaseNotes,
    this.fileSize,
  });
}

final updateInfoProvider = FutureProvider<AppUpdate?>((ref) async {
  try {
    final res = await http.get(
      Uri.parse('https://api.github.com/repos/Kalo-Weather/Kalo-Android/releases/latest'),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );
    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final tagName = body['tag_name'] as String? ?? '';
    final releaseNotes = body['body'] as String?;
    final assets = body['assets'] as List<dynamic>? ?? [];

    final apkAsset = assets.cast<Map<String, dynamic>>().firstWhere(
      (a) => (a['name'] as String? ?? '').endsWith('.apk'),
      orElse: () => <String, dynamic>{},
    );
    final downloadUrl = apkAsset['browser_download_url'] as String?;
    if (tagName.isEmpty || downloadUrl == null) return null;

    return AppUpdate(
      version: tagName.replaceFirst('v', ''),
      downloadUrl: downloadUrl,
      releaseNotes: releaseNotes,
      fileSize: apkAsset['size'] as int?,
    );
  } catch (_) {
    return null;
  }
});

final currentVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

Future<String> downloadApk(String url, {void Function(double progress)? onProgress, CancelToken? cancelToken}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/kalo-update.apk');
  final client = http.Client();

  try {
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);
    if (response.statusCode != 200) {
      throw Exception('Download failed: ${response.statusCode}');
    }

    final totalBytes = response.contentLength ?? 0;
    var receivedBytes = 0;
    final sink = file.openWrite();

    await for (final chunk in response.stream) {
      cancelToken?.throwIfCancelled();
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0 && onProgress != null) {
        onProgress(receivedBytes / totalBytes);
      }
    }

    await sink.close();
    return file.path;
  } finally {
    client.close();
  }
}

class CancelToken {
  bool _cancelled = false;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw Exception('Download cancelled');
  }
}

Future<bool> installApk(String filePath) async {
  final result = await OpenFile.open(filePath);
  return result.type == ResultType.done;
}

bool isNewerVersion(String remote, String current) {
  final rParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final maxLen = rParts.length > cParts.length ? rParts.length : cParts.length;
  for (var i = 0; i < maxLen; i++) {
    final r = i < rParts.length ? rParts[i] : 0;
    final c = i < cParts.length ? cParts[i] : 0;
    if (r != c) return r > c;
  }
  return false;
}
