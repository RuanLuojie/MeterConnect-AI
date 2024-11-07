import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  String _apiUrl = "https://sql-server.fly.dev/execute";
  String _dbUser = "";
  String _dbPassword = "";
  String _openAiApiUrl = "https://api.openai.com/v1/chat/completions";
  String _openAiApiKey = "";
  bool _rememberSettings = false;
  bool _isDbPasswordVisible = false;
  bool _isOpenAiKeyVisible = false;

  SettingsViewModel() {
    _loadSettings(); // 初始化时加载设置
  }

  // Getters
  String get apiUrl => _rememberSettings ? _apiUrl : "https://sql-server.fly.dev/execute";
  String get dbUser => _rememberSettings ? _dbUser : "";
  String get dbPassword => _rememberSettings ? _dbPassword : "";
  String get openAiApiUrl => _rememberSettings ? _openAiApiUrl : "https://api.openai.com/v1/chat/completions";
  String get openAiApiKey => _rememberSettings ? _openAiApiKey : "";
  bool get rememberSettings => _rememberSettings;
  bool get isDbPasswordVisible => _isDbPasswordVisible;
  bool get isOpenAiKeyVisible => _isOpenAiKeyVisible;

  // Setters
  void setApiUrl(String value) {
    _apiUrl = value;
    _saveSettings();
    notifyListeners();
  }

  void setDbUser(String value) {
    _dbUser = value;
    _saveSettings();
    notifyListeners();
  }

  void setDbPassword(String value) {
    _dbPassword = value;
    _saveSettings();
    notifyListeners();
  }

  void setOpenAiApiUrl(String value) {
    _openAiApiUrl = value;
    _saveSettings();
    notifyListeners();
  }

  void setOpenAiApiKey(String value) {
    _openAiApiKey = value;
    _saveSettings();
    notifyListeners();
  }

  void setRememberSettings(bool value) {
    _rememberSettings = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleDbPasswordVisibility() {
    _isDbPasswordVisible = !_isDbPasswordVisible;
    notifyListeners();
  }

  void toggleOpenAiKeyVisibility() {
    _isOpenAiKeyVisible = !_isOpenAiKeyVisible;
    notifyListeners();
  }

  // 保存设置到 SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('apiUrl', _apiUrl);
    prefs.setString('dbUser', _dbUser);
    prefs.setString('dbPassword', _dbPassword);
    prefs.setString('openAiApiUrl', _openAiApiUrl);
    prefs.setString('openAiApiKey', _openAiApiKey);
    prefs.setBool('rememberSettings', _rememberSettings);
  }

  // 从 SharedPreferences 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiUrl = prefs.getString('apiUrl') ?? "https://sql-server.fly.dev/execute";
    _dbUser = prefs.getString('dbUser') ?? "";
    _dbPassword = prefs.getString('dbPassword') ?? "";
    _openAiApiUrl = prefs.getString('openAiApiUrl') ?? "https://api.openai.com/v1/chat/completions";
    _openAiApiKey = prefs.getString('openAiApiKey') ?? "";
    _rememberSettings = prefs.getBool('rememberSettings') ?? false;
    notifyListeners();
  }
}
