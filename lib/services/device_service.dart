import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceServiceProvider = Provider((ref) => DeviceService());

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _fingerprintKey = 'kalo_device_fingerprint';

  Future<String> getHardwareFingerprint() async {
    final buffer = StringBuffer();

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      buffer.write('android:');
      buffer.write(androidInfo.board);
      buffer.write(':');
      buffer.write(androidInfo.brand);
      buffer.write(':');
      buffer.write(androidInfo.device);
      buffer.write(':');
      buffer.write(androidInfo.hardware);
      buffer.write(':');
      buffer.write(androidInfo.manufacturer);
      buffer.write(':');
      buffer.write(androidInfo.model);
      buffer.write(':');
      buffer.write(androidInfo.id);
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      buffer.write('ios:');
      buffer.write(iosInfo.model);
      buffer.write(':');
      buffer.write(iosInfo.identifierForVendor);
    } else {
      buffer.write('unknown_device');
    }

    // Append installation-specific secret as additional entropy
    final storedEntropy = await _secureStorage.read(key: _fingerprintKey);
    if (storedEntropy != null) {
      buffer.write(':');
      buffer.write(storedEntropy);
    }

    return buffer.toString();
  }

  Future<void> ensureFingerprintEntropy() async {
    final exists = await _secureStorage.containsKey(key: _fingerprintKey);
    if (!exists) {
      // Generate a random installation ID bound to the platform keychain
      final uuid = _generateUuid();
      await _secureStorage.write(key: _fingerprintKey, value: uuid);
    }
  }

  String _generateUuid() {
    // Simple v4-style UUID without external dependency
    final r = _Random();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    return '${_hex(bytes[0])}${_hex(bytes[1])}${_hex(bytes[2])}${_hex(bytes[3])}-'
        '${_hex(bytes[4])}${_hex(bytes[5])}-'
        '${_hex(bytes[6])}${_hex(bytes[7])}-'
        '${_hex(bytes[8])}${_hex(bytes[9])}-'
        '${_hex(bytes[10])}${_hex(bytes[11])}${_hex(bytes[12])}${_hex(bytes[13])}${_hex(bytes[14])}${_hex(bytes[15])}';
  }

  String _hex(int v) => v.toRadixString(16).padLeft(2, '0');
}

class _Random {
  int _seed = DateTime.now().microsecondsSinceEpoch;

  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }
}
