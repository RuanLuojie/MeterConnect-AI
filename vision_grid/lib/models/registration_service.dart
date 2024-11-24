import 'package:http/http.dart' as http;
import 'dart:convert';
import '../viewmodels/settings_viewmodel.dart';

class RegistrationService {
  static const String apiEndpoint =
      'https://sql-sever-v3api.fly.dev/api/SqlApi/send-email';

  Future<bool> registerUser(SettingsViewModel settingsViewModel) async {
    try {
      final apiKey = settingsViewModel.apiKey;
      final email = settingsViewModel.email.trim();
      final idCode = settingsViewModel.idCode.trim();
      final meterType = settingsViewModel.meterType.trim();

      if (email.isEmpty || idCode.isEmpty || meterType.isEmpty) {
        print("數據不完整：email=$email, idCode=$idCode, meterType=$meterType");
        return false;
      }

      final payload = {
        "toEmail": email,
        "userIdCode": idCode,
        "meterType": meterType,
      };

      final body = jsonEncode(payload);

      final headers = {
        'Content-Type': 'application/json',
        'X-API-KEY': apiKey,
      };

      print("Request headers: $headers");
      print("Request body: $body");

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print("註冊成功！");
        return true;
      } else {
        print("註冊失敗：${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("註冊時發生錯誤：$e");
      return false;
    }
  }
}
