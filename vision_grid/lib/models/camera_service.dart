import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // 確保導入 image 套件
import '../viewmodels/settings_viewmodel.dart';

class CameraService {
  static Future<bool> uploadImage(String base64Image, BuildContext context) async {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);

    Map<String, dynamic> data = {
      "db_name": "postgres",
      "db_user": settings.dbUser,
      "db_password": settings.dbPassword,
      "query": """
      INSERT INTO image_data (id, image_base64)
      VALUES (DEFAULT, '$base64Image');
    """
    };

    try {
      final response = await http.post(
        Uri.parse(settings.apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('上傳失敗: $e');
      return false;
    }
  }

  // 新增 cropImage 方法
  static img.Image cropImage(img.Image capturedImage, int cropLeft, int cropTop, int cropWidth, int cropHeight) {
    // 確保裁剪區域合法
    cropLeft = cropLeft.clamp(0, capturedImage.width - 1);
    cropTop = cropTop.clamp(0, capturedImage.height - 1);
    cropWidth = cropWidth.clamp(0, capturedImage.width - cropLeft);
    cropHeight = cropHeight.clamp(0, capturedImage.height - cropTop);

    // 使用 image 套件的 copyCrop 方法進行裁剪
    return img.copyCrop(capturedImage, x: cropLeft, y: cropTop, width: cropWidth, height: cropHeight);
  }
}
