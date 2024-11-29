import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyNotificationService {
  static const String apiEndpoint =
      'https://sql-sever-v3api.fly.dev/api/SqlApi/send-email'; // 替換為真實的 API 端點

  Future<List<Map<String, dynamic>>> fetchAnomalies(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return _detectAnomalies(data);
      } else {
        throw Exception('Failed to fetch usage data');
      }
    } catch (e) {
      print('Error fetching anomalies: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _detectAnomalies(List<dynamic> usageData) {
    if (usageData.isEmpty) return [];

    final totalUsage = usageData.fold(0.0, (sum, item) => sum + double.parse(item['usage']));
    final averageUsage = totalUsage / usageData.length;
    final tolerance = 0.2; // 允許的誤差範圍

    List<Map<String, dynamic>> anomalies = [];
    for (var item in usageData) {
      final currentUsage = double.parse(item['usage']);
      if (currentUsage > averageUsage * (1 + tolerance)) {
        anomalies.add({
          '異常數據': currentUsage.toStringAsFixed(2),
          '平均值': averageUsage.toStringAsFixed(2),
          '誤差': '${((currentUsage / averageUsage - 1) * 100).toStringAsFixed(1)}%',
          '時間': item['time'],
        });
      }
    }
    return anomalies;
  }
}
