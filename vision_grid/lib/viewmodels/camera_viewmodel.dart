import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../models/camera_service.dart';
import '../models/openai_service.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:convert';

class CameraViewModel extends ChangeNotifier {
  late CameraController _controller;
  final OpenAIService _openAIService = OpenAIService();
  String? recognizedText;

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
      Uint8List imageData, String recognizedText, BuildContext context) async {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);
    try {
      bool uploadSuccess = await CameraService.uploadImage(
          imageData, settings.meterType, recognizedText, context);
      print('上傳結果: $uploadSuccess');

      return uploadSuccess;
    } catch (e) {
      print('上傳失敗，錯誤: $e');
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
