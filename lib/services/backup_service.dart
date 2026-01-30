import 'dart:convert';
import 'dart:io';
import 'package:passwords_vault/models/user_session.dart';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';
import 'encryption_service.dart';
import '../models/password_entry.dart';

class BackupService {
  static Future<File> createBackupFile(String masterPassword) async {
    try {
      final passwords = await StorageService.getPasswords();
      final session = await StorageService.getUserSession();

      final backupData = {
        'passwords': passwords.map((p) => p.toJson()).toList(),
        'session': session?.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'app': 'PasswordVault',
      };

      final jsonString = jsonEncode(backupData);
      final encrypted = EncryptionService.encryptData(
        jsonString,
        masterPassword,
      );

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/password_vault_backup_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(encrypted);

      return file;
    } catch (e) {
      throw Exception('Backup creation failed: $e');
    }
  }

  static Future<void> restoreBackup(
    String encryptedBackup,
    String masterPassword,
  ) async {
    try {
      final decrypted = EncryptionService.decryptData(
        encryptedBackup,
        masterPassword,
      );
      final backupData = jsonDecode(decrypted);

      if (backupData['passwords'] != null) {
        final List<dynamic> passwordsJson = backupData['passwords'];
        final passwords = passwordsJson
            .map((json) => PasswordEntry.fromJson(json))
            .toList();
        await StorageService.savePasswords(passwords);
      }

      if (backupData['session'] != null) {
        final session = UserSession.fromJson(backupData['session']);
        await StorageService.saveUserSession(session);
      }
    } catch (e) {
      throw Exception('Restore failed: Wrong password or corrupted backup');
    }
  }
}
