import 'package:http/http.dart' as http;
import 'dart:convert';
import '../viewmodels/settings_viewmodel.dart';

class RegistrationService {
  static const String apiEndpoint =
      'https://sql-sever-v3api.fly.dev/api/SqlApi/send-email';

  Future<Map<String, dynamic>> registerUser(SettingsViewModel settingsViewModel) async {
    try {
      final apiKey = settingsViewModel.apiKey;
      final email = settingsViewModel.email.trim();
      final idCode = settingsViewModel.idCode.trim();
      final meterType = settingsViewModel.meterType.trim();

      if (email.isEmpty || idCode.isEmpty || meterType.isEmpty) {
        return {
          'success': false,
          'message': "數據不完整：email=$email, idCode=$idCode, meterType=$meterType"
        };
      }

      final meterTypeMapping = {
        "電表": "electric",
        "瓦斯表": "gas",
      };
      final mappedMeterType = meterTypeMapping[meterType] ?? meterType;

      final payload = {
        "toEmail": email,
        "userIdCode": idCode,
        "meterType": mappedMeterType,
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
        return {'success': true, 'message': "註冊成功！"};
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ?? '未知錯誤';
        return {
          'success': false,
          'message': "註冊失敗：$errorMessage",
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': "註冊時發生錯誤：$e",
      };
    }
  }

}
