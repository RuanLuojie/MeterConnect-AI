import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../viewmodels/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
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
      final cameraViewModel = Provider.of<CameraViewModel>(context, listen: false);
      availableCameras().then((cameras) {
        cameraViewModel.initializeCamera(cameras);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera")),
      body: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.initializeControllerFuture == null) {
            return Center(child: CircularProgressIndicator());
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
                        viewModel.setExposurePoint(details.localPosition, previewSize);
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
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text(
                          '請將方框對準數字錶盤',
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
                            _showCapturedImage(context, imageData);
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

  void _showCapturedImage(BuildContext parentContext, Uint8List imageData) {
    // 重置狀態
    setState(() {
      _isUploading = true; // 開始上傳/辨識
      recognizedText = null; // 清空上次的辨識結果
    });

    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              // 在這裡調用 `_recognizeTextWithAI` 方法，並將 `dialogSetState` 傳遞給它
              _recognizeTextWithAI(parentContext, imageData, dialogSetState);

              return Container(
                width: 300,
                constraints: BoxConstraints(maxHeight: 400), // 限制對話框高度
                padding: EdgeInsets.all(10),
                child: ListView( // 使用 ListView 替代 Column
                  shrinkWrap: true,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 250,
                        height: 250,
                        child: Image.memory(imageData),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (recognizedText != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "辨識結果: $recognizedText",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_isUploading)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                          strokeWidth: 3.0,
                        ),
                      ),
                    if (!_isUploading && recognizedText != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // 確認按鈕的邏輯
                            },
                            child: Text('確認'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('取消'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _recognizeTextWithAI(BuildContext context, Uint8List imageData, StateSetter dialogSetState) async {
    final cameraViewModel = Provider.of<CameraViewModel>(context, listen: false);
    try {
      // 传入 imageData 和 context 两个参数
      final result = await cameraViewModel.recognizeNumber(imageData, context);
      dialogSetState(() { // 使用Dialog的setState
        _isUploading = false;
        recognizedText = result ?? "無法辨識數字"; // 防止空值
      });
    } catch (e) {
      print('辨識過程中出現錯誤: $e');
      dialogSetState(() {
        _isUploading = false;
        recognizedText = '辨識失敗';
      });
    }
  }


}

// CustomPainter for the alignment rectangle
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

    final double rectWidth = size.width * 0.7; // 2:7 aspect ratio
    final double rectHeight = size.height * 0.2;

    final double left = (size.width - rectWidth) / 2;
    final double top = (size.height - rectHeight) / 5;
    final double right = left + rectWidth;
    final double bottom = top + rectHeight;

    final Rect rect = Rect.fromLTRB(left, top, right, bottom);

    // Draw the border rectangle
    canvas.drawRect(rect, borderPaint);

    // Draw white corners
    final double cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right corner
    canvas.drawLine(Offset(right, top), Offset(right - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - cornerLength), cornerPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), cornerPaint);

    // Draw the transparent grey overlay outside the rectangle
    final Paint overlayPaint = Paint()
      ..color = Colors.black38.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Top overlay
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), overlayPaint);
    // Bottom overlay
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), overlayPaint);
    // Left overlay
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), overlayPaint);
    // Right overlay
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), overlayPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
