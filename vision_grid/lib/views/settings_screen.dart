import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.apiUrl),
              decoration: InputDecoration(labelText: 'API URL'),
              onChanged: (value) => settings.setApiUrl(value),
            ),
            SizedBox(height: 16),
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.dbUser),
              decoration: InputDecoration(labelText: 'Database User'),
              onChanged: (value) => settings.setDbUser(value),
            ),
            SizedBox(height: 16),
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.dbPassword),
              decoration: InputDecoration(labelText: 'Database Password'),
              obscureText: true,
              onChanged: (value) => settings.setDbPassword(value),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text("記住設定"),
              activeColor: Colors.white, // 設定選中的顏色為白色
              // checkColor: Colors.black, // 設置勾選標記為黑色（可選）
              value: settings.rememberSettings,
              onChanged: (bool? value) {
                settings.setRememberSettings(value ?? false);
              },
            ),

          ],
        ),
      ),
    );
  }
}
