import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView( // 使用 SingleChildScrollView 包裹
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SQL API URL
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.apiUrl),
              decoration: InputDecoration(labelText: 'SQL API URL'),
              onChanged: (value) => settings.setApiUrl(value),
            ),
            SizedBox(height: 16),
            // Database User
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.dbUser),
              decoration: InputDecoration(labelText: 'Database User'),
              onChanged: (value) => settings.setDbUser(value),
            ),
            SizedBox(height: 16),
            // Database Password with eye button
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.dbPassword),
              decoration: InputDecoration(
                labelText: 'Database Password',
                suffixIcon: IconButton(
                  icon: Icon(settings.isDbPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: settings.toggleDbPasswordVisibility,
                ),
              ),
              obscureText: !settings.isDbPasswordVisible,
              onChanged: (value) => settings.setDbPassword(value),
            ),
            SizedBox(height: 16),
            // OpenAI API URL
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.openAiApiUrl),
              decoration: InputDecoration(labelText: 'OpenAI API URL'),
              onChanged: (value) => settings.setOpenAiApiUrl(value),
            ),
            SizedBox(height: 16),
            // OpenAI API Key with eye button
            TextField(
              cursorColor: Colors.white,
              controller: TextEditingController(text: settings.openAiApiKey),
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                suffixIcon: IconButton(
                  icon: Icon(settings.isOpenAiKeyVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: settings.toggleOpenAiKeyVisibility,
                ),
              ),
              obscureText: !settings.isOpenAiKeyVisible,
              onChanged: (value) => settings.setOpenAiApiKey(value),
            ),
            SizedBox(height: 16),
            // Remember settings checkbox
            CheckboxListTile(
              title: Text("記住設定"),
              activeColor: Colors.white,
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
