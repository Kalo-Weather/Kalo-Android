import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

Uint8List deriveHardwareKey(String hardwareFingerprint) {
  final bytes = utf8.encode(hardwareFingerprint);
  final digest = sha256.convert(bytes);
  return Uint8List.fromList(digest.bytes);
}

String _aesGcmEncrypt(String plainText, enc.Key key) {
  final iv = enc.IV.fromSecureRandom(12);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  final ct = encrypted.bytes;
  if (ct.length < 16) {
    throw Exception("Ciphertext too short — missing GCM tag");
  }
  final cipherText = ct.sublist(0, ct.length - 16);
  final tag = ct.sublist(ct.length - 16);
  return "${iv.base16}:${_bytesToHex(cipherText)}:${_bytesToHex(tag)}";
}

String _aesGcmDecrypt(String encryptedPayload, enc.Key key) {
  final parts = encryptedPayload.split(':');
  if (parts.length != 3) {
    throw Exception("Malformed encrypted payload — expected 3 parts");
  }
  final iv = enc.IV.fromBase16(parts[0]);
  final cipherText = _hexToBytes(parts[1]);
  final tag = _hexToBytes(parts[2]);
  final combined = Uint8List.fromList([...cipherText, ...tag]);
  final encrypted = enc.Encrypted(combined);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
  return encrypter.decrypt(encrypted, iv: iv);
}

// Encrypt keys using AES-256-GCM before storing in secure storage.
// Key is derived from the device hardware fingerprint.
String encryptLocalKey(String plainApiKey, String hardwareFingerprint) {
  final keyBytes = deriveHardwareKey(hardwareFingerprint);
  return _aesGcmEncrypt(plainApiKey, enc.Key(keyBytes));
}

// Decrypt key on-device right before making an API call.
String decryptLocalKey(String encryptedStoredKey, String hardwareFingerprint) {
  final keyBytes = deriveHardwareKey(hardwareFingerprint);
  return _aesGcmDecrypt(encryptedStoredKey, enc.Key(keyBytes));
}

// Encrypt an API key for transmission to the proxy server.
// Uses the shared DECRYPTION_SECRET (32 bytes / 64 hex chars) that
// the server uses to decrypt provider keys.
String encryptForProxy(String plainApiKey, String decryptionSecretHex) {
  final keyBytes = _hexToBytes(decryptionSecretHex);
  if (keyBytes.length != 32) {
    throw Exception("Decryption secret must be 32 bytes (64 hex chars)");
  }
  return _aesGcmEncrypt(plainApiKey, enc.Key(Uint8List.fromList(keyBytes)));
}

String _bytesToHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

List<int> _hexToBytes(String hex) {
  final result = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    result.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return result;
}
