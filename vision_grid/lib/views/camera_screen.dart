import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
  final String displayPromptText;

  CameraScreen({this.displayPromptText = '請將方框對準數字錶盤'});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isUploading = false;
  String _uploadMessage = '';
  String? recognizedText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cameraViewModel =
          Provider.of<CameraViewModel>(context, listen: false);
      availableCameras().then((cameras) {
        cameraViewModel.initializeCamera(cameras);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsViewModel>(context, listen: false);
    final currentMeterType = settings.meterType;

    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.initializeControllerFuture == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<void>(
            future: viewModel.initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        final Size previewSize = MediaQuery.of(context).size;
                        viewModel.setExposurePoint(
                            details.localPosition, previewSize);
                      },
                      child: CameraPreview(viewModel.controller),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: Size(double.infinity, double.infinity),
                        painter: RectPainter(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "當前設定錶類型：$currentMeterType",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text(
                          currentMeterType == "電錶"
                              ? "請將方框對準電錶讀數"
                              : "請將方框對準瓦斯錶讀數",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: MediaQuery.of(context).size.width / 2 - 30,
                      child: FloatingActionButton(
                        onPressed: () async {
                          setState(() {
                            _isUploading = false;
                            _uploadMessage = '';
                          });
                          Uint8List? imageData = await viewModel.capturePhoto();
                          if (imageData != null) {
                            await _showCapturedImage(context, imageData);
                          }
                        },
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Camera error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _showCapturedImage(
      BuildContext parentContext, Uint8List imageData) async {
    String? result = await showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: CapturedImageDialogContent(
            imageData: imageData,
            parentContext: parentContext,
          ),
        );
      },
    );

    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }
}

class RectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final double rectWidth = size.width * 0.7;
    final double rectHeight = size.height * 0.2;

    final double left = (size.width - rectWidth) / 2;
    final double top = (size.height - rectHeight) / 5;
    final double right = left + rectWidth;
    final double bottom = top + rectHeight;

    final Rect rect = Rect.fromLTRB(left, top, right, bottom);

    canvas.drawRect(rect, borderPaint);

    final double cornerLength = 20.0;

    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    canvas.drawLine(
        Offset(right, top), Offset(right - cornerLength, top), cornerPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    canvas.drawLine(
        Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left, bottom - cornerLength), cornerPaint);

    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom),
        cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength),
        cornerPaint);

    final Paint overlayPaint = Paint()
      ..color = Colors.black38.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), overlayPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, bottom, size.width, size.height), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), overlayPaint);
    canvas.drawRect(
        Rect.fromLTRB(right, top, size.width, bottom), overlayPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CapturedImageDialogContent extends StatefulWidget {
  final Uint8List imageData;
  final BuildContext parentContext;

  CapturedImageDialogContent({
    required this.imageData,
    required this.parentContext,
  });

  @override
  _CapturedImageDialogContentState createState() =>
      _CapturedImageDialogContentState();
}

class _CapturedImageDialogContentState
    extends State<CapturedImageDialogContent> {
  bool _isUploading = true;
  String? recognizedText;

  @override
  void initState() {
    super.initState();
    _recognizeTextWithAI();
  }

  Future<void> _recognizeTextWithAI() async {
    final cameraViewModel =
        Provider.of<CameraViewModel>(widget.parentContext, listen: false);
    try {
      final result = await cameraViewModel.recognizeNumber(
        widget.imageData,
        widget.parentContext,
      );
      setState(() {
        _isUploading = false;
        recognizedText = result ?? "無法辨識";
      });
    } catch (e) {
      print('辨識過程中出現錯誤: $e');
      setState(() {
        _isUploading = false;
        recognizedText = '辨識失敗';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      constraints: const BoxConstraints(maxHeight: 400),
      padding: const EdgeInsets.all(10),
      child: ListView(
        shrinkWrap: true,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 250,
              height: 250,
              child: Image.memory(widget.imageData),
            ),
          ),
          const SizedBox(height: 20),
          if (recognizedText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "辨識結果: $recognizedText",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (_isUploading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!_isUploading && recognizedText != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    print('確認按鈕被點擊');
                    final cameraViewModel = Provider.of<CameraViewModel>(
                        widget.parentContext,
                        listen: false);

                    setState(() {
                      _isUploading = true;
                    });

                    bool uploadSuccess = await cameraViewModel.uploadImageToServer(
                        widget.imageData, recognizedText ?? '', widget.parentContext);

                    setState(() {
                      _isUploading = false;
                    });

                    if (uploadSuccess) {
                      print('圖片上傳成功');
                      Navigator.of(context).pop('上傳成功');
                    } else {
                      print('圖片上傳失敗');
                      Navigator.of(context).pop('上傳失敗');
                    }
                  },
                  child: const Text('確認'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
