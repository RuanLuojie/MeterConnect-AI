import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/camera_service.dart';
import '../viewmodels/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
          // 確保 `initializeControllerFuture` 被正確初始化
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
                    // 添加對準框
                    Align(
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: Size(double.infinity, double.infinity),
                        painter: RectPainter(),
                      ),
                    ),
                    // 在對準框上方顯示文本
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50), // 調整文本位置
                        child: Text(
                          '請將方框對準數字錶盤',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    // 拍照按鈕
                    Positioned(
                      bottom: 60,
                      left: MediaQuery.of(context).size.width / 2 - 30,
                      child: FloatingActionButton(
                        onPressed: () async {
                          setState(() {
                            _isUploading = false; // 恢復按鈕狀態
                            _uploadMessage = ''; // 清空錯誤信息
                          });
                          Uint8List? imageData = await viewModel.capturePhoto();
                          if (imageData != null) {
                            _showCapturedImage(context, imageData);
                          }
                        },
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40, // 調整圖標大小
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black, // 加入相機圖案
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

  // 添加狀態變量來追踪上傳狀態
  bool _isUploading = false;
  String _uploadMessage = '';

  void _showCapturedImage(BuildContext parentContext, Uint8List imageData) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // 设置弹出视窗的圆角
              ),
              child: Container(
                width: 300, // 设置弹出视窗宽度
                height: 400, // 设置弹出视窗高度
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 使用 ClipRRect 来实现图片的圆角
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 250, // 设置图片的宽度
                        height: 250, // 设置图片的高度
                        child: Image.memory(
                          imageData,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isUploading
                        ? Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70), // 设置颜色
                          strokeWidth: 3.0, // 设置转圈的宽度
                        ),
                        SizedBox(height: 10),
                        Text(_uploadMessage), // 显示上传信息
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isUploading = true;
                              _uploadMessage = '正在上傳...';
                            });

                            // 执行上传
                            bool success = await Provider.of<CameraViewModel>(parentContext, listen: false)
                                .uploadImageToServer(imageData);

                            // 上传成功或失败的处理
                            if (success) {
                              setState(() {
                                _uploadMessage = '上傳成功！';
                              });
                              // 延迟 2 秒后关闭对话框
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                _uploadMessage = '上傳失敗，請稍後重试';
                              });
                              // 保留失败信息 2 秒后再切回初始状态
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('確認'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭视窗
                          },
                          child: Text('取消'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
