import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _rememberApiKey = false;
  bool _isLoading = false; // 用於顯示載入狀態

  @override
  void initState() {
    super.initState();
    _loadSavedApiKey();
  }

  Future<void> _loadSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberApiKey = prefs.getBool('rememberApiKey') ?? false;
      if (_rememberApiKey) {
        _apiKeyController.text = prefs.getString('apiKey') ?? '';
      }
    });
  }

  Future<void> _saveApiKeyAndUserData(String apiKey, String dbUser, String dbPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
    await prefs.setString('dbUser', dbUser);
    await prefs.setString('dbPassword', dbPassword);
    await prefs.setBool('rememberApiKey', _rememberApiKey);
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

              // API Key TextField
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
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

              // Remember API Key Checkbox
              CheckboxListTile(
                title: Text("記住 API Key"),
                value: _rememberApiKey,
                activeColor: Colors.white,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberApiKey = value ?? false;
                  });
                },
              ),
              SizedBox(height: 24),

              // Login Button
              _isLoading
                  ? CircularProgressIndicator() // 顯示載入進度指示器
                  : ElevatedButton(
                onPressed: () {
                  _handleLogin();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final apiKey = _apiKeyController.text;

    if (apiKey.isNotEmpty) {
      setState(() {
        _isLoading = true; // 開始載入狀態
      });

      // 呼叫伺服器 API 驗證並取得用戶資訊
      final userInfo = await _verifyApiKeyAndGetUserInfo(apiKey);

      setState(() {
        _isLoading = false; // 結束載入狀態
      });

      if (userInfo != null) {
        // 儲存 API Key 和用戶資料
        await _saveApiKeyAndUserData(apiKey, userInfo['username'], userInfo['password']);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid API Key. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your API Key')),
      );
    }
  }

  Future<Map<String, dynamic>?> _verifyApiKeyAndGetUserInfo(String apiKey) async {
    // 替換為實際的 API 驗證端點
    final url = Uri.parse("https://sql-sever-v3api.fly.dev/api/SqlApi/user-info");

    try {
      final response = await http.get(url, headers: {
        'X-API-KEY': apiKey,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'username': data['username'],
          'password': data['password'],
          'database': data['database'],
        };
      } else {
        return null; // 驗證失敗
      }
    } catch (e) {
      print('API 驗證失敗: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
