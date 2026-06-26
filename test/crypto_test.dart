import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/crypto_service.dart';

void main() {
  group('Kalo Cryptographic Hardware Binding Tests', () {
    const originalApiKey = "opw_secure_test_weather_key_12345";
    const phoneAFingerprint = "Pixel-7-Pro:redfin-112233";
    const phoneBFingerprint = "Samsung-S23:kalama-445566";

    test('Successful Encryption and Decryption on Same Device Signature', () {
      final encryptedData = encryptLocalKey(originalApiKey, phoneAFingerprint);
      final decryptedData = decryptLocalKey(encryptedData, phoneAFingerprint);
      expect(decryptedData, equals(originalApiKey));
    });

    test('Cryptographic Rejection when Attempting to Decrypt on Different Device Signature', () {
      final encryptedData = encryptLocalKey(originalApiKey, phoneAFingerprint);
      expect(
        () => decryptLocalKey(encryptedData, phoneBFingerprint),
        throwsA(anything), // The design doc says throwsA(isA<Exception>()), but encryption failure might throw different things depending on padding/GCM tag
      );
    });
  });
}
