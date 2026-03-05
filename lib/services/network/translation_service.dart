import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../utils/keys.dart';

class TranslationService {
  final String _apiKey = APIKeys.geminiApiKey;
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  Future<TranslationResult> translateSpeech({
    required Uint8List audioData,
    required String sourceLang,
    required String targetLang,
  }) async {
    final url = "$_baseUrl?key=$_apiKey";
    
    final prompt = """
    Identify the speech in the provided audio. 
    Translate it from $sourceLang to $targetLang.
    Response format (JSON):
    {
      "original": "text in source language",
      "translated": "text in target language"
    }
    Only return raw JSON.
    """;

    final body = {
      "contents": [{
        "parts": [
          {"text": prompt},
          {
            "inline_data": {
              "mime_type": "audio/pcm;rate=16000",
              "data": base64Encode(audioData)
            }
          }
        ]
      }],
      "generationConfig": {
        "response_mime_type": "application/json",
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultText = data['candidates'][0]['content']['parts'][0]['text'];
        final jsonResult = jsonDecode(resultText);
        
        return TranslationResult(
          original: jsonResult['original'] ?? "",
          translated: jsonResult['translated'] ?? "",
        );
      } else {
        throw Exception("Failed to translate: ${response.body}");
      }
    } catch (e) {
      print("Translation Error: $e");
      return TranslationResult(original: "Ошибка", translated: "Не удалось перевести: $e");
    }
  }
}

class TranslationResult {
  final String original;
  final String translated;
  TranslationResult({required this.original, required this.translated});
}
