import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UsageDataService {
  static const String _baseUrl = "https://sql-sever-v3api.fly.dev/api/SqlApi/PhotoRecords";


  // 獲取用量數據
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

  // 檢測異常數據
  List<Map<String, dynamic>> detectAnomalies(
      List<Map<String, dynamic>> usageData,
      {double tolerance = 0.2}) {
    if (usageData.isEmpty) return [];

    // 計算平均用量
    final totalUsage = usageData.fold(0.0, (sum, item) {
      final usage = double.tryParse(item['recognized_text'] ?? '0') ?? 0;
      return sum + usage;
    });
    final averageUsage = totalUsage / usageData.length;

    List<Map<String, dynamic>> anomalies = [];

    for (var item in usageData) {
      final currentUsage = double.tryParse(item['recognized_text'] ?? '0') ?? 0;

      // 判斷是否超出允許範圍
      if (currentUsage > averageUsage * (1 + tolerance)) {
        // 解析和格式化時間
        final capturedTime = DateTime.parse(item['captured_time']);
        final formattedTime = DateFormat('yyyy/MM/dd \n HH:mm:ss', 'zh_TW').format(capturedTime);


        anomalies.add({
          '異常數據': currentUsage.toStringAsFixed(2),
          '平均值': averageUsage.toStringAsFixed(2),
          '誤差':
          '${((currentUsage / averageUsage - 1) * 100).toStringAsFixed(1)}%',
          '時間': formattedTime,
        });
      }
    }

    return anomalies;
  }

}
