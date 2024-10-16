import 'package:flutter/material.dart';
import 'views/home_screen.dart';
import 'views/themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Grid',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: HomeScreen(),
    );
  }
}
