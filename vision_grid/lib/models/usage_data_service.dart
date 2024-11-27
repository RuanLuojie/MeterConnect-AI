import 'dart:convert';
import 'package:http/http.dart' as http;

class UsageDataService {
  static const String _baseUrl = "https://sql-sever-v3api.fly.dev/api/SqlApi/PhotoRecords";

  Future<List<Map<String, dynamic>>> fetchUsageData(String apiKey) async {
    print("正在使用的 API Key: $apiKey");
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          "X-API-KEY": apiKey,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        print("API 請求失敗，HTTP 狀態碼: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("發生錯誤: $e");
      return [];
    }
  }
}
