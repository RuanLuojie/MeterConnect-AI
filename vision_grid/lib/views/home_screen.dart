// 在 HomeScreen 中
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 新增
import 'camera_screen.dart';
import '../viewmodels/camera_viewmodel.dart'; // 新增

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Grid'),
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
            return index == 0
                ? ElevatedButton.icon(
              onPressed: () {
                // 包裝 `CameraScreen` 與 `Provider`
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
            )
                : ElevatedButton(
              onPressed: () {
                // 其他按鈕的功能
              },
              child: Text('按鈕 ${index + 1}'),
            );
          },
        ),
      ),
    );
  }
}
