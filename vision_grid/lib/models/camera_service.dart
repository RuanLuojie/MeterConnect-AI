import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../viewmodels/settings_viewmodel.dart';

class CameraService {
  static Future<bool> uploadImage(Uint8List imageData, String meterType,
      String recognizedText, BuildContext context) async {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://sql-sever-v3api.fly.dev/api/SqlApi/upload-image"),
      );

      request.headers.addAll({
        "Content-Type": "multipart/form-data",
        "X-API-KEY": settings.apiKey,
      });

      request.fields['meterType'] = meterType;
      request.fields['recognizedText'] = recognizedText;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageData,
          filename: 'image.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('圖片上傳成功: ${responseBody.body}');
        return true;
      } else {
        print('圖片上傳失敗: ${responseBody.statusCode} ${responseBody.body}');
        return false;
      }
    } catch (e) {
      print('上傳失敗: $e');
      return false;
    }
  }

  static img.Image cropImage(img.Image capturedImage, int cropLeft, int cropTop,
      int cropWidth, int cropHeight) {
    cropLeft = cropLeft.clamp(0, capturedImage.width - 1);
    cropTop = cropTop.clamp(0, capturedImage.height - 1);
    cropWidth = cropWidth.clamp(0, capturedImage.width - cropLeft);
    cropHeight = cropHeight.clamp(0, capturedImage.height - cropTop);

    return img.copyCrop(capturedImage,
        x: cropLeft, y: cropTop, width: cropWidth, height: cropHeight);
  }
}
