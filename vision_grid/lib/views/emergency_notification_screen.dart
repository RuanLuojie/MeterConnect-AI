import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usage_data_service.dart';
import '../viewmodels/settings_viewmodel.dart';

class EmergencyNotificationScreen extends StatefulWidget {
  @override
  _EmergencyNotificationScreenState createState() =>
      _EmergencyNotificationScreenState();
}

class _EmergencyNotificationScreenState
    extends State<EmergencyNotificationScreen> {
  List<Map<String, dynamic>> _anomalies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnomalies();
  }

  Future<void> _fetchAnomalies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = Provider.of<SettingsViewModel>(context, listen: false);
      final usageDataService = UsageDataService();

      // 獲取所有用量數據
      final usageData = await usageDataService.fetchUsageData(settings.apiKey);

      // 檢測異常數據
      final anomalies =
      usageDataService.detectAnomalies(usageData, tolerance: 0.2);

      setState(() {
        _anomalies = anomalies;
        _isLoading = false;
      });
    } catch (e) {
      print("異常數據加載失敗: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('緊急通知'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '異常電表數據',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _anomalies.isEmpty
                ? Center(
              child: Text(
                '未檢測到異常數據',
                style: TextStyle(fontSize: 16),
              ),
            )
                : Expanded(
              child: ListView.separated(
                itemCount: _anomalies.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final data = _anomalies[index];
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                '異常數據: ${data['異常數據']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '平均值: ${data['平均值']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '誤差: ${data['誤差']}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            data['時間'] ?? '',
                            textAlign: TextAlign.end,
                            style:
                            TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
