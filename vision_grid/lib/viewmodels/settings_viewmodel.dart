import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {

  SettingsViewModel() {
    loadSettings(); // 初始化时加载设置
  }

  String _apiUrl = "https://sql-server.fly.dev/execute";
  String _dbUser = "";
  String _dbPassword = "";
  String _openAiApiUrl = "https://api.openai.com/v1/chat/completions";
  String _openAiApiKey = "";
  bool _rememberSettings = false;
  bool _isDbPasswordVisible = false;
  bool _isOpenAiKeyVisible = false;
  String _idCode = "";

  // Getters
  String get apiUrl => _apiUrl;
  String get dbUser => _dbUser;
  String get dbPassword => _dbPassword;
  String get openAiApiUrl => _openAiApiUrl;
  String get openAiApiKey => _openAiApiKey;
  bool get rememberSettings => _rememberSettings;
  bool get isDbPasswordVisible => _isDbPasswordVisible;
  bool get isOpenAiKeyVisible => _isOpenAiKeyVisible;
  String get idCode => _idCode;

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

  void setIdCode(String value) {
    _idCode = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberSettings', _rememberSettings);

    if (_rememberSettings) {
      prefs.setString('apiUrl', _apiUrl);
      prefs.setString('dbUser', _dbUser);
      prefs.setString('dbPassword', _dbPassword);
      prefs.setString('openAiApiUrl', _openAiApiUrl);
      prefs.setString('openAiApiKey', _openAiApiKey);
      prefs.setString('idCode', _idCode);
    } else {
      prefs.remove('apiUrl');
      prefs.remove('dbUser');
      prefs.remove('dbPassword');
      prefs.remove('openAiApiUrl');
      prefs.remove('openAiApiKey');
      prefs.remove('idCode');
    }
  }


  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiUrl = prefs.getString('apiUrl') ??
        "https://sql-sever-v3api.fly.dev/api/SqlApi/dev-execute";
    _dbUser = prefs.getString('dbUser') ?? "";
    _dbPassword = prefs.getString('dbPassword') ?? "";
    _openAiApiUrl = prefs.getString('openAiApiUrl') ??
        "https://api.openai.com/v1/chat/completions";
    _openAiApiKey = prefs.getString('openAiApiKey') ?? "";
    _rememberSettings = prefs.getBool('rememberSettings') ?? false;
    _idCode = prefs.getString('idCode') ?? "";
    notifyListeners();
  }
}
