import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIVisionService {
  static const String _proxyUrl = "http://95.163.236.215:8000/v1/proxy/vision";

  Future<String> analyzeImage(File imageFile) async {
    const licenseKey = "JRV-M7VK-EX4J"; // Default testing key

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
              "text": "Ты — J.A.R.V.I.S., эксперт-лингвист. Опиши кратко, что изображено на фото, и переведи любой текст на нем на русский язык. Будь лаконичен и профессионален."
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
      "max_tokens": 500
    };

    try {
      final response = await http.post(
        Uri.parse(_proxyUrl),
        headers: {
          "Content-Type": "application/json",
          "x-license-key": licenseKey,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      } else {
        return "Ошибка: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Сетевая ошибка: $e";
    }
  }
}
