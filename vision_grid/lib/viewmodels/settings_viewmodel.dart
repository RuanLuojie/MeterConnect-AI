import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String _apiUrl = "https://sql-server.fly.dev/execute";
  String _dbUser = "roger";
  String _dbPassword = "Asdffhgeg1134!";
  String _openAiApiUrl = "https://api.openai.com/v1/chat/completions";
  String _openAiApiKey = "sk-None-k30bCJqYi0WII8omCt9DT3BlbkFJPBCd4VLFvrQ3hXW02fBE";
  bool _rememberSettings = false;
  bool _isDbPasswordVisible = false; // 用于控制数据库密码可见性
  bool _isOpenAiKeyVisible = false; // 用于控制OpenAI密钥可见性

  // Getters
  String get apiUrl => _rememberSettings ? _apiUrl : "https://sql-server.fly.dev/execute";
  String get dbUser => _rememberSettings ? _dbUser : "roger";
  String get dbPassword => _rememberSettings ? _dbPassword : "Asdffhgeg1134!";
  String get openAiApiUrl => _rememberSettings ? _openAiApiUrl : "https://api.openai.com/v1/chat/completions";
  String get openAiApiKey => _rememberSettings ? _openAiApiKey : "sk-None-k30bCJqYi0WII8omCt9DT3BlbkFJPBCd4VLFvrQ3hXW02fBE";
  bool get rememberSettings => _rememberSettings;
  bool get isDbPasswordVisible => _isDbPasswordVisible;
  bool get isOpenAiKeyVisible => _isOpenAiKeyVisible;

  // Setters
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

  void setOpenAiApiUrl(String value) {
    _openAiApiUrl = value;
    notifyListeners();
  }

  void setOpenAiApiKey(String value) {
    _openAiApiKey = value;
    notifyListeners();
  }

  void setRememberSettings(bool value) {
    _rememberSettings = value;
    notifyListeners();
  }

  // Methods to toggle visibility for each password field
  void toggleDbPasswordVisibility() {
    _isDbPasswordVisible = !_isDbPasswordVisible;
    notifyListeners();
  }

  void toggleOpenAiKeyVisibility() {
    _isOpenAiKeyVisible = !_isOpenAiKeyVisible;
    notifyListeners();
  }
}
