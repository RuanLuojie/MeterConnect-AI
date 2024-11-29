import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../models/camera_service.dart';
import '../models/openai_service.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CameraViewModel extends ChangeNotifier {
  late CameraController _controller;
  final OpenAIService _openAIService = OpenAIService();
  String? recognizedText;

  // 狀態：是否為辨識模式
  bool _isRecognitionMode = false;

  bool get isRecognitionMode => _isRecognitionMode;

  void setRecognitionMode(bool value) {
    _isRecognitionMode = value;
    notifyListeners();
  }

  Future<String?> recognizeNumber(
      Uint8List imageData, BuildContext context) async {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);
    return await _openAIService.recognizeNumber(
      imageData,
      settings.openAiApiUrl,
      settings.openAiApiKey,
    );
  }

  Future<void>? initializeControllerFuture;

  CameraController get controller => _controller;

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    initializeControllerFuture = _controller.initialize().then((_) async {
      await _controller.setExposureMode(ExposureMode.auto);
      await _controller.setFlashMode(FlashMode.off);
      notifyListeners();
    });
  }

  Future<Uint8List?> capturePhoto() async {
    if (!_controller.value.isInitialized) return null;

    try {
      await _controller.setFlashMode(FlashMode.off);

      final XFile imageFile = await _controller.takePicture();
      Uint8List imageData = await imageFile.readAsBytes();

      img.Image? capturedImage = img.decodeImage(imageData);

      if (capturedImage != null) {
        final double rectWidth = capturedImage.width * 0.7;
        final double rectHeight = capturedImage.height * 0.2;
        final double left = (capturedImage.width - rectWidth) / 2;
        final double top = (capturedImage.height - rectHeight) / 5;

        int cropLeft = left.round();
        int cropTop = top.round();
        int cropWidth = rectWidth.round();
        int cropHeight = rectHeight.round();

        img.Image croppedImage = CameraService.cropImage(
            capturedImage, cropLeft, cropTop, cropWidth, cropHeight);

        return Uint8List.fromList(img.encodeJpg(croppedImage));
      } else {
        return imageData;
      }
    } catch (e) {
      debugPrint('Capture photo failed: $e');
      return null;
    }
  }

  Future<bool> uploadImageToServer(
      Uint8List imageData,
      String recognizedText,
      BuildContext context,
      ) async {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);

    try {
      if (_isRecognitionMode) {
        // 辨識模式，僅執行辨識
        print('辨識模式啟用，進行文字辨識...');
        recognizedText = await recognizeNumber(imageData, context) ?? '';
        if (recognizedText.isEmpty) {
          print('辨識失敗，未能獲取結果。');
          return false;
        }
        print('辨識成功，結果：$recognizedText');
        return true;
      } else {
        // 普通模式，執行上傳
        print('普通模式啟用，進行圖片上傳...');
        bool uploadSuccess = await CameraService.uploadImage(
          imageData,
          settings.meterType,
          recognizedText,
          context,
        );
        print('上傳結果: $uploadSuccess');
        return uploadSuccess;
      }
    } catch (e) {
      print('處理失敗，錯誤: $e');
      return false;
    }
  }



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
