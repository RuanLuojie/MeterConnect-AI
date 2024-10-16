import 'dart:async';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class CameraService {
  // 裁剪圖片的邏輯
  static img.Image cropImage(img.Image capturedImage, int cropLeft, int cropTop, int cropWidth, int cropHeight) {
    // 確保裁剪區域合法
    cropLeft = cropLeft.clamp(0, capturedImage.width - 1);
    cropTop = cropTop.clamp(0, capturedImage.height - 1);
    cropWidth = cropWidth.clamp(0, capturedImage.width - cropLeft);
    cropHeight = cropHeight.clamp(0, capturedImage.height - cropTop);

    return img.copyCrop(capturedImage, x: cropLeft, y: cropTop, width: cropWidth, height: cropHeight);
  }

  // 上傳圖片到 API
  static Future<bool> uploadImage(String base64Image) async {
    Map<String, dynamic> data = {
      "db_name": "postgres",
      "db_user": "roger",
      "db_password": "Asdffhgeg1134!",
      "query": """
      INSERT INTO image_data (id, image_base64)
      VALUES (DEFAULT, '$base64Image');
    """
    };

    try {
      // 設置超時時間，例如 10 秒
      final response = await http
          .post(
        Uri.parse('https://sql-server.fly.dev/execute'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(data),
      )
          .timeout(Duration(seconds:5)); // 設置超時

      if (response.statusCode == 200) {
        return true; // 上傳成功
      } else {
        print('上傳失敗，狀態碼: ${response.statusCode}');
        return false;
      }
    } on TimeoutException catch (e) {
      print('上傳超時: $e'); // 超時異常
      return false;
    } catch (e) {
      print('上傳錯誤: $e');
      return false; // 返回 false
    }
  }
}
