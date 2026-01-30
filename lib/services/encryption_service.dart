import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static encrypt.Key _generateKey(String masterPassword) {
    final hash = hashPassword(masterPassword);
    final keyString = hash.substring(0, 32); // 32 characters for AES-256
    return encrypt.Key.fromUtf8(keyString);
  }

  static String encryptData(String data, String masterPassword) {
    try {
      final key = _generateKey(masterPassword);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  static String decryptData(String encryptedData, String masterPassword) {
    try {
      final key = _generateKey(masterPassword);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  static bool verifyPassword(String inputPassword, String storedHash) {
    final inputHash = hashPassword(inputPassword);
    return inputHash == storedHash;
  }
}
