import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/password_entry.dart';
import '../models/user_session.dart';
import '../utils/app_constants.dart';

class StorageService {
  static Future<void> saveMasterPassword(String passwordHash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.masterPasswordKey, passwordHash);
  }

  static Future<String?> getMasterPasswordHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.masterPasswordKey);
  }

  static Future<bool> hasMasterPassword() async {
    final hash = await getMasterPasswordHash();
    return hash != null && hash.isNotEmpty;
  }

  static Future<void> saveUserSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.userEmailKey,
      jsonEncode(session.toJson()),
    );
  }

  static Future<UserSession?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(AppConstants.userEmailKey);
    if (sessionJson == null) return null;
    return UserSession.fromJson(jsonDecode(sessionJson));
  }

  static Future<void> savePasswords(List<PasswordEntry> passwords) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = passwords.map((p) => p.toJson()).toList();
    await prefs.setString(AppConstants.passwordsKey, jsonEncode(jsonList));
  }

  static Future<List<PasswordEntry>> getPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final passwordsJson = prefs.getString(AppConstants.passwordsKey);

    if (passwordsJson == null || passwordsJson.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(passwordsJson);
    return decoded.map((json) => PasswordEntry.fromJson(json)).toList();
  }

  static Future<void> addPassword(PasswordEntry password) async {
    final passwords = await getPasswords();
    passwords.add(password);
    await savePasswords(passwords);
  }

  static Future<void> updatePassword(PasswordEntry updatedPassword) async {
    final passwords = await getPasswords();
    final index = passwords.indexWhere((p) => p.id == updatedPassword.id);
    if (index != -1) {
      passwords[index] = updatedPassword;
      await savePasswords(passwords);
    }
  }

  static Future<void> deletePassword(String id) async {
    final passwords = await getPasswords();
    passwords.removeWhere((p) => p.id == id);
    await savePasswords(passwords);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveBackupData(String encryptedData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.backupDataKey, encryptedData);
  }

  static Future<String?> getBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.backupDataKey);
  }
}
