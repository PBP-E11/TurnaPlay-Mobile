import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _role = "user"; // default to user
  bool _isAdmin = false;
  String _username = "";
  String _email = "";
  String _displayName = "";

  String get role => _role;
  bool get isAdmin => _isAdmin;
  String get username => _username;
  String get email => _email;
  String get displayName => _displayName;

  bool get isOrganizerOrAdmin => _role == 'organizer' || _role == 'admin' || _isAdmin;

  Future<void> login(String username, String role, bool isAdmin, {String email = "", String displayName = ""}) async {
    _username = username;
    _role = role;
    _isAdmin = isAdmin;
    _email = email;
    _displayName = displayName;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role);
    await prefs.setBool('isAdmin', isAdmin);
    await prefs.setString('email', email);
    await prefs.setString('displayName', displayName);
  }

  Future<void> logout() async {
    _role = "user";
    _isAdmin = false;
    _username = "";
    _email = "";
    _displayName = "";
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role');
    await prefs.remove('isAdmin');
    await prefs.remove('email');
    await prefs.remove('displayName');
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? "";
    _role = prefs.getString('role') ?? "user";
    _isAdmin = prefs.getBool('isAdmin') ?? false;
    _email = prefs.getString('email') ?? "";
    _displayName = prefs.getString('displayName') ?? "";
    notifyListeners();
  }
}
