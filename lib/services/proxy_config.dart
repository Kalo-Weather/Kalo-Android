import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _defaultBaseUrl = 'https://kalo-vercel.vercel.app';

const _urlStorageKey = 'kalo_proxy_base_url';

final proxyBaseUrlProvider = StateNotifierProvider<ProxyBaseUrlNotifier, String>((ref) {
  return ProxyBaseUrlNotifier();
});

class ProxyBaseUrlNotifier extends StateNotifier<String> {
  ProxyBaseUrlNotifier() : super(_initialUrl());

  static String _initialUrl() {
    final envUrl = dotenv.env['KALO_PROXY_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    return _defaultBaseUrl;
  }

  Future<void> load() async {
    const storage = FlutterSecureStorage();
    final stored = await storage.read(key: _urlStorageKey);
    if (stored != null && stored.isNotEmpty) {
      state = stored;
    }
  }

  Future<void> setUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    // Ensure it's a valid URL with scheme and no trailing slash
    final normalized = (trimmed.startsWith('http') ? trimmed : 'https://$trimmed').replaceAll(RegExp(r'/+$'), '');
    state = normalized;
    const storage = FlutterSecureStorage();
    await storage.write(key: _urlStorageKey, value: normalized);
  }

  Future<void> resetToDefault() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _urlStorageKey);
    state = _initialUrl();
  }
}

class ProxyConfig {
  static const String clientVersion = '1.2.0';

  static String? get clientSecret => dotenv.env['KALO_CLIENT_SECRET'];
}
