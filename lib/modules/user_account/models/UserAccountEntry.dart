// To parse this JSON data, do
//
//     final userAccountEntry = userAccountEntryFromJson(jsonString);

import 'dart:convert';

UserAccountEntry userAccountEntryFromJson(String str) =>
    UserAccountEntry.fromJson(json.decode(str));

String userAccountEntryToJson(UserAccountEntry data) =>
    json.encode(data.toJson());

class UserAccountEntry {
  List<UserAccount> userAccount;

  UserAccountEntry({required this.userAccount});

  factory UserAccountEntry.fromJson(Map<String, dynamic> json) =>
      UserAccountEntry(
        userAccount: List<UserAccount>.from(
          json["user_account"].map((x) => UserAccount.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "user_account": List<dynamic>.from(userAccount.map((x) => x.toJson())),
  };
}

class UserAccount {
  String id;
  String username;
  String email;
  String displayName;
  String role;
  String profileImage;
  bool isActive;
  DateTime dateJoined;
  DateTime? lastLogin;

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.role,
    required this.profileImage,
    required this.isActive,
    required this.dateJoined,
    required this.lastLogin,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
    id: json["id"] ?? "",
    username: json["username"] ?? "",
    email: json["email"] ?? "",
    displayName: json["display_name"] ?? "",
    role: json["role"] ?? "",
    profileImage: json["profile_image"] ?? "",
    isActive: json["is_active"] ?? false,
    dateJoined: DateTime.parse(
      json["date_joined"] ?? DateTime.now().toIso8601String(),
    ),
    lastLogin: json["last_login"] == null
        ? null
        : DateTime.parse(json["last_login"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "display_name": displayName,
    "role": role,
    "profile_image": profileImage,
    "is_active": isActive,
    "date_joined": dateJoined.toIso8601String(),
    "last_login": lastLogin?.toIso8601String(),
  };
}
