import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  SecurityService._internal();
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _kKeyStorageKey = 'novahealth_symmetric_key_v1';
  final Cipher _aesGcm = AesGcm.with256bits();

  /// Call once during app startup
  Future<void> init() async {
    await _getOrCreateKey();
  }

  /// Public accessor for Hive encryption key (32 bytes)
  Future<Uint8List> getKey() async {
    return await _getOrCreateKey();
  }

  // -------- Secure random bytes --------
  Uint8List _secureRandomBytes(int length) {
    final r = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => r.nextInt(256)),
    );
  }

  // -------- Key management --------
  Future<Uint8List> _getOrCreateKey() async {
    final existing = await _secureStorage.read(key: _kKeyStorageKey);
    if (existing != null) {
      try {
        return base64Decode(existing);
      } catch (_) {
        if (kDebugMode) {
          debugPrint('Invalid stored key, regenerating');
        }
      }
    }

    final newKey = _secureRandomBytes(32); // 256-bit
    await _secureStorage.write(
      key: _kKeyStorageKey,
      value: base64Encode(newKey),
    );
    return newKey;
  }

  // -------- Encryption helpers --------
  Future<String> encryptString(String plain) async {
    final key = SecretKey(await _getOrCreateKey());
    final nonce = _secureRandomBytes(12);

    final encrypted = await _aesGcm.encrypt(
      utf8.encode(plain),
      secretKey: key,
      nonce: nonce,
    );

    final payload = {
      'n': base64Encode(nonce),
      'c': base64Encode(encrypted.cipherText),
      't': base64Encode(encrypted.mac.bytes),
    };

    return base64Encode(utf8.encode(jsonEncode(payload)));
  }

  Future<String> decryptString(String payloadB64) async {
    final decoded = jsonDecode(utf8.decode(base64Decode(payloadB64)));

    final box = SecretBox(
      base64Decode(decoded['c']),
      nonce: base64Decode(decoded['n']),
      mac: Mac(base64Decode(decoded['t'])),
    );

    final key = SecretKey(await _getOrCreateKey());
    final clear = await _aesGcm.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }

  Future<String> encryptJsonMap(Map<String, dynamic> map) async {
    return encryptString(jsonEncode(map));
  }
}
