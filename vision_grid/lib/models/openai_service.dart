import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class OpenAIService {
  Future<String?> recognizeNumber(Uint8List imageData, String apiUrl, String apiKey) async {
    final base64Image = base64Encode(imageData);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "你是數字辨識模型，辨識圖中的數字，數字以外的數據可以不用辨識"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image"
                },
              },
            ],
          }
        ],
        "max_tokens": 20
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty && data['choices'][0]['message'] != null) {
        String content = data['choices'][0]['message']['content'];
        String result = content.replaceAll(RegExp(r'[^0-9]'), '');

        return result.isNotEmpty ? result : null;
      } else {
        print('辨識失敗: 格式錯誤，未找到預期的 choices 或 message');
        return null;
      }
    } else {
      print('辨識失敗: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
