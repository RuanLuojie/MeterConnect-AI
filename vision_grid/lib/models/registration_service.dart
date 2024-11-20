import 'package:http/http.dart' as http;
import 'dart:convert';
import '../viewmodels/settings_viewmodel.dart';

class RegistrationService {
  static const String apiEndpoint = 'https://sql-sever-v3api.fly.dev/api/SqlApi/send-email';

  Future<bool> registerUser(SettingsViewModel settingsViewModel) async {
    try {
      // 從 ViewModel 獲取資料
      final apiKey = settingsViewModel.apiKey;
      final email = settingsViewModel.email.trim();
      final idCode = settingsViewModel.idCode.trim();
      final meterType = settingsViewModel.meterType.trim(); // 新增字段

      // 驗證資料是否完整
      if (email.isEmpty || idCode.isEmpty || meterType.isEmpty) {
        print("數據不完整：email=$email, idCode=$idCode, meterType=$meterType");
        return false;
      }

      // 組裝 JSON Body
      final payload = {
        "toEmail": email,
        "userIdCode": idCode,
        "meterType": meterType, // 新增字段
      };

      final body = jsonEncode(payload);

      // 設定請求 Header
      final headers = {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey, // API 驗證密鑰
      };

      // 印出測試資料（用於 Debug）
      print("Request headers: $headers");
      print("Request body: $body");

      // 發送 POST 請求
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: body,
      );

      // 處理回應結果
      if (response.statusCode == 200) {
        print("註冊成功！");
        return true;
      } else {
        // 印出錯誤訊息
        print("註冊失敗：${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      // 捕捉例外錯誤並印出
      print("註冊時發生錯誤：$e");
      return false;
    }
  }
}
