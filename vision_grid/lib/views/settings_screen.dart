import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController apiUrlController;
  late TextEditingController dbUserController;
  late TextEditingController dbPasswordController;
  late TextEditingController openAiApiUrlController;
  late TextEditingController openAiApiKeyController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsViewModel>(context, listen: false);

    apiUrlController = TextEditingController(text: settings.apiUrl);
    dbUserController = TextEditingController(text: settings.dbUser);
    dbPasswordController = TextEditingController(text: settings.dbPassword);
    openAiApiUrlController = TextEditingController(text: settings.openAiApiUrl);
    openAiApiKeyController = TextEditingController(text: settings.openAiApiKey);
  }

  @override
  void dispose() {
    apiUrlController.dispose();
    dbUserController.dispose();
    dbPasswordController.dispose();
    openAiApiUrlController.dispose();
    openAiApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: settings.meterType,
              items: [
                DropdownMenuItem(value: "電表", child: Text("電表")),
                DropdownMenuItem(value: "瓦斯表", child: Text("瓦斯表")),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.setMeterType(value);
                }
              },
              decoration: InputDecoration(
                labelText: '表類型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: apiUrlController,
              decoration: InputDecoration(labelText: 'SQL API URL'),
              onChanged: (value) => settings.setApiUrl(value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: dbUserController,
              decoration: InputDecoration(labelText: 'User'),
              onChanged: (value) => settings.setDbUser(value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: dbPasswordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(settings.isDbPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: settings.toggleDbPasswordVisibility,
                ),
              ),
              obscureText: !settings.isDbPasswordVisible,
              onChanged: (value) => settings.setDbPassword(value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: openAiApiUrlController,
              decoration: InputDecoration(labelText: 'OpenAI API URL'),
              onChanged: (value) => settings.setOpenAiApiUrl(value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: openAiApiKeyController,
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                suffixIcon: IconButton(
                  icon: Icon(settings.isOpenAiKeyVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: settings.toggleOpenAiKeyVisibility,
                ),
              ),
              obscureText: !settings.isOpenAiKeyVisible,
              onChanged: (value) => settings.setOpenAiApiKey(value),
            ),
            SizedBox(height: 16),
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
