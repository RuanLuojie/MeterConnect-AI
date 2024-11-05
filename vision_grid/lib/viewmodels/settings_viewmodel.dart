import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String _apiUrl = "https://sql-server.fly.dev/execute";
  String _dbUser = "roger";
  String _dbPassword = "Asdffhgeg1134!";
  bool _rememberSettings = false; // 新增

  String get apiUrl => _rememberSettings ? _apiUrl : "https://sql-server.fly.dev/execute";
  String get dbUser => _rememberSettings ? _dbUser : "roger";
  String get dbPassword => _rememberSettings ? _dbPassword : "Asdffhgeg1134!";
  bool get rememberSettings => _rememberSettings;

  void setApiUrl(String value) {
    _apiUrl = value;
    notifyListeners();
  }

  void setDbUser(String value) {
    _dbUser = value;
    notifyListeners();
  }

  void setDbPassword(String value) {
    _dbPassword = value;
    notifyListeners();
  }

  void setRememberSettings(bool value) {
    _rememberSettings = value;
    notifyListeners();
  }
}
