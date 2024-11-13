import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'camera_screen.dart';
import '../viewmodels/camera_viewmodel.dart';
import 'settings_screen.dart';
import '../login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Grid'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // 導航回登入頁面並清除返回堆疊
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 按鈕一行顯示兩個
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 3, // 三個按鈕
          itemBuilder: (context, index) {
            if (index == 0) {
              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => CameraViewModel(),
                        child: CameraScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('相機'),
              );
            } else if (index == 1) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                child: const Text('設定'),
              );
            }

          },
        ),
      ),
    );
  }
}
