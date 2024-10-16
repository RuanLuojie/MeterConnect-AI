import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/camera_service.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:convert';

class CameraViewModel extends ChangeNotifier {
  late CameraController _controller;
  Future<void>? initializeControllerFuture;

  CameraController get controller => _controller;

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    // 創建 CameraController
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    // 初始化控制器
    initializeControllerFuture = _controller.initialize().then((_) async {
      await _controller.setExposureMode(ExposureMode.auto);
      await _controller.setFlashMode(FlashMode.off);
      notifyListeners(); // 通知視圖更新
    });
  }

  Future<Uint8List?> capturePhoto() async {
    if (!_controller.value.isInitialized) return null;

    try {
      final XFile imageFile = await _controller.takePicture();
      Uint8List imageData = await imageFile.readAsBytes();

      // 使用 `decodeImage` 解码捕获的图像
      img.Image? capturedImage = img.decodeImage(imageData);

      if (capturedImage != null) {
        // 根据方框的位置和尺寸裁剪图像
        final double rectWidth = capturedImage.width * 0.7; // 与 RectPainter 保持一致
        final double rectHeight = capturedImage.height * 0.2;
        final double left = (capturedImage.width - rectWidth) / 2;
        final double top = (capturedImage.height - rectHeight) / 5;

        // 将方框的相对位置转换成实际像素位置
        int cropLeft = left.round();
        int cropTop = top.round();
        int cropWidth = rectWidth.round();
        int cropHeight = rectHeight.round();

        // 使用 `CameraService.cropImage` 方法裁剪图像
        img.Image croppedImage = CameraService.cropImage(capturedImage, cropLeft, cropTop, cropWidth, cropHeight);

        // 返回裁剪后的图像数据
        return Uint8List.fromList(img.encodeJpg(croppedImage));
      } else {
        return imageData; // 返回原始图像数据
      }
    } catch (e) {
      debugPrint('Capture photo failed: $e');
      return null;
    }
  }

  Future<bool> uploadImageToServer(Uint8List imageData) async {
    String base64Image = base64Encode(imageData);

    try {
      bool uploadSuccess = await CameraService.uploadImage(base64Image);
      print('上傳結果: $uploadSuccess'); // 確認 uploadSuccess 是否為 false

      if (!uploadSuccess) {
        print('上傳失敗: 伺服器返回 false。');
        return false;
      }

      return uploadSuccess;
    } catch (e) {
      print('上傳失敗，錯誤: $e');
      return false;
    }
  }

  // 設定曝光點
  Future<void> setExposurePoint(Offset point, Size previewSize) async {
    if (_controller.value.isInitialized) {
      final Offset normalizedPoint = Offset(
        point.dx / previewSize.width,
        point.dy / previewSize.height,
      );
      await _controller.setExposurePoint(normalizedPoint);
    }
  }

  void disposeController() {
    _controller.dispose();
  }
}
