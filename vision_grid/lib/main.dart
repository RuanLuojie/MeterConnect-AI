import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'views/home_screen.dart';
import 'views/themes.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/registration_viewmodel.dart';
import 'viewmodels/camera_viewmodel.dart';
import 'viewmodels/usage_data_viewmodel.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('zh_TW', null);

  final settingsViewModel = SettingsViewModel();
  await settingsViewModel.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsViewModel),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => UsageDataViewModel()),
        ChangeNotifierProvider(
          create: (_) => RegistrationViewModel(settingsViewModel),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);

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
