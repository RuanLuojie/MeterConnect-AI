import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = 'sk-None-k30bCJqYi0WII8omCt9DT3BlbkFJPBCd4VLFvrQ3hXW02fBE'; // 請確認這是你的完整且有效的 OpenAI API Key

  Future<String?> recognizeNumber(Uint8List imageData) async {
    // 將圖片轉換為 Base64 字串
    final base64Image = base64Encode(imageData);

    // 發送請求到 OpenAI API
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini", // 確保這是正確的模型名稱
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "你是數字辨識模型，數字以外的數據可以不用辨識"
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

    // 檢查請求結果
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 檢查 choices 和 message 是否存在
      if (data['choices'] != null && data['choices'].isNotEmpty && data['choices'][0]['message'] != null) {
        String content = data['choices'][0]['message']['content'];

        // 使用正則表達式過濾，只保留數字字符
        String result = content.replaceAll(RegExp(r'[^0-9]'), '');

        return result.isNotEmpty ? result : null; // 回傳處理過的連續數字串
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
