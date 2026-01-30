class UserSession {
  String email;
  String masterPasswordHash;
  DateTime lastBackup;
  bool isLoggedIn;

  UserSession({
    required this.email,
    required this.masterPasswordHash,
    required this.lastBackup,
    this.isLoggedIn = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'masterPasswordHash': masterPasswordHash,
      'lastBackup': lastBackup.toIso8601String(),
      'isLoggedIn': isLoggedIn,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      email: json['email'],
      masterPasswordHash: json['masterPasswordHash'],
      lastBackup: DateTime.parse(json['lastBackup']),
      isLoggedIn: json['isLoggedIn'] ?? true,
    );
  }
}
