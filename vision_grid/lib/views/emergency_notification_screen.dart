import 'package:flutter/material.dart';

class EmergencyNotificationScreen extends StatelessWidget {
  final List<Map<String, String>> _fakeData = [
    {'異常數據': '2300.45', '誤差': '15%', '時間': '2024-11-19 10:30'},
    {'異常數據': '2800.12', '誤差': '20%', '時間': '2024-11-19 11:45'},
    {'異常數據': '3100.00', '誤差': '25%', '時間': '2024-11-19 12:15'},
  ];

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
            Expanded(
              child: ListView.separated(
                itemCount: _fakeData.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final data = _fakeData[index];
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: TextStyle(color: Colors.grey[600]),
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
