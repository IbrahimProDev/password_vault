import 'package:flutter/material.dart';
import 'package:passwords_vault/utils/app_colours.dart';

class AppConstants {
  static const String appName = 'Secure Pass Vault';
  static const String appVersion = '1.0.0';

  static const String masterPasswordKey = 'master_password';
  static const String passwordsKey = 'passwords';
  static const String userEmailKey = 'user_email';
  static const String backupDataKey = 'backup_data';

  static const List<String> categories = [
    'Social Media',
    'Banking',
    'Email',
    'Shopping',
    'Work',
    'Entertainment',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Social Media': Icons.people_rounded,
    'Banking': Icons.account_balance_rounded,
    'Email': Icons.email_rounded,
    'Shopping': Icons.shopping_cart_rounded,
    'Work': Icons.work_rounded,
    'Entertainment': Icons.movie_rounded,
    'Other': Icons.folder_rounded,
  };

  static const Map<String, Color> categoryColors = {
    'Social Media': AppColors.socialMedia,
    'Banking': AppColors.banking,
    'Email': AppColors.email,
    'Shopping': AppColors.shopping,
    'Work': AppColors.work,
    'Entertainment': AppColors.entertainment,
    'Other': AppColors.other,
  };
}
