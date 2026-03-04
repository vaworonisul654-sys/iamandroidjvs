import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../utils/keys.dart';

class OpenAIVisionService {
  static const String _baseUrl = "https://api.openai.com/v1/chat/completions";

  Future<String> analyzeImage(File imageFile) async {
    final apiKey = APIKeys.openAiApiKey;
    if (apiKey == "YOUR_OPENAI_API_KEY_HERE") {
      return "Ошибка: API ключ OpenAI не настроен.";
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text", 
              "text": "Ты — J.A.R.V.I.S. Опиши кратко, что ты видишь на этом фото, и дай полезный совет или инсайт на русском языке. Будь краток и профессионален."
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:image/jpeg;base64,$base64Image"
              }
            }
          ]
        }
      ],
      "max_tokens": 300
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      } else {
        return "Ошибка API: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Ошибка сети: $e";
    }
  }
}
