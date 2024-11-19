import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home_screen.dart';
import 'views/themes.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'login_screen.dart';
import 'viewmodels/camera_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsViewModel = SettingsViewModel();
  await settingsViewModel.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsViewModel),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context);

    // 检查是否自动登录
    final isRememberApiKey = settings.rememberSettings &&
        settings.dbUser.isNotEmpty &&
        settings.dbPassword.isNotEmpty;

    return MaterialApp(
      title: 'Vision Grid',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      initialRoute: isRememberApiKey ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
