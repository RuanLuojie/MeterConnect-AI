import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'viewmodels/settings_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _rememberApiKey = false;
  bool _isLoading = false;

  static const String _adminPassword = '1134';

  @override
  void initState() {
    super.initState();
    _loadSavedApiKey();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedApiKey = prefs.getString('apiKey');
    final rememberApiKey = prefs.getBool('rememberApiKey') ?? false;

    if (rememberApiKey && savedApiKey != null) {
      setState(() {
        _isLoading = true;
      });

      final userInfo = await _verifyApiKeyAndGetUserInfo(savedApiKey);

      setState(() {
        _isLoading = false;
      });

      if (userInfo != null) {
        final settings = Provider.of<SettingsViewModel>(context, listen: false);
        settings.setDbUser(userInfo['username']);
        settings.setDbPassword(userInfo['password']);

        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _loadSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRememberApiKey = prefs.getBool('rememberApiKey') ?? false;
    final savedApiKey = prefs.getString('apiKey') ?? '';

    setState(() {
      _rememberApiKey = savedRememberApiKey;
      if (_rememberApiKey) {
        _apiKeyController.text = savedApiKey;
      }
    });
  }

  Future<void> _saveApiKeyAndUserData(
      String apiKey, String dbUser, String dbPassword, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberApiKey', _rememberApiKey);

    if (_rememberApiKey) {
      await prefs.setString('apiKey', apiKey);
      await prefs.setString('dbUser', dbUser);
      await prefs.setString('dbPassword', dbPassword);
      await prefs.setString('email', email);
    } else {
      await prefs.remove('apiKey');
      await prefs.remove('dbUser');
      await prefs.remove('dbPassword');
      await prefs.remove('email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/vision_grid.png',
                  height: 100,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key 或 管理員密碼',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  floatingLabelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text("記住 API Key"),
                value: _rememberApiKey,
                activeColor: Colors.white,
                onChanged: (bool? value) async {
                  setState(() {
                    _rememberApiKey = value ?? false;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('rememberApiKey', _rememberApiKey);
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text('登入'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin({bool autoLogin = false}) async {
    final input = _apiKeyController.text.trim();

    if (input.isEmpty) {
      if (!autoLogin) {
        _showSnackBar('請輸入您的 API Key 或 管理員密碼');
      }
      return;
    }

    if (input == _adminPassword) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    setState(() => _isLoading = true);

    final userInfo = await _verifyApiKeyAndGetUserInfo(input);

    setState(() => _isLoading = false);

    if (userInfo != null) {
      await _saveApiKeyAndUserData(
          input, userInfo['username'], userInfo['password'], userInfo['email']);

      final settings = Provider.of<SettingsViewModel>(context, listen: false);
      settings.setDbUser(userInfo['username']);
      settings.setDbPassword(userInfo['password']);
      settings.setEmail(userInfo['email']);
      settings.setApiKey(input);
      settings.setRememberSettings(_rememberApiKey);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!autoLogin) {
        _showSnackBar('無效的 API Key，請重試。');
      }
    }
  }

  Future<Map<String, dynamic>?> _verifyApiKeyAndGetUserInfo(
      String apiKey) async {
    final url =
        Uri.parse("https://sql-sever-v3api.fly.dev/api/SqlApi/user-info");

    try {
      final response = await http.get(url, headers: {'X-API-KEY': apiKey});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'username': data['username'],
          'password': data['password'],
          'database': data['database'],
          'email': data['email'],
        };
      }
    } catch (e) {
      print('API 驗證失敗: $e');
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
