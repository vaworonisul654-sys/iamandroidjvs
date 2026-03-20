import 'package:flutter/material.dart';
import '../models/language.dart';
import '../services/audio/audio_capture_service.dart';
import '../services/network/gemini_live_service.dart';

class TranslatorViewModel extends ChangeNotifier {
  bool isRecording = false;
  List<TranslationItem> history = [];
  String currentTranslation = "";
  String? error;

  // Language State
  Language sourceLanguage = Language.english;
  Language targetLanguage = Language.russian;

  // Services
  final AudioCaptureService _audioCaptureService = AudioCaptureService();
  final GeminiLiveService _geminiLiveService = GeminiLiveService();

  TranslatorViewModel() {
    _setupGeminiCallbacks();
  }

  void _setupGeminiCallbacks() {
    _geminiLiveService.onTranslatedText = (text) {
      currentTranslation += text;
      notifyListeners();
    };

    _geminiLiveService.onTurnComplete = () {
      if (currentTranslation.isNotEmpty) {
        history.insert(0, TranslationItem(
          originalText: "Voice Input", 
          translatedText: currentTranslation,
        ));
        currentTranslation = "";
        notifyListeners();
      }
    };

    _geminiLiveService.onError = (errMsg) {
      error = errMsg;
      isRecording = false;
      notifyListeners();
    };
  }

  void setSourceLanguage(Language lang) {
    sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(Language lang) {
    targetLanguage = lang;
    notifyListeners();
  }

  void switchLanguages() {
    final temp = sourceLanguage;
    sourceLanguage = targetLanguage;
    targetLanguage = temp;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    error = null;
    if (isRecording) {
      await _stopSession();
    } else {
      await _startSession();
    }
  }

  Future<void> _startSession() async {
    isRecording = true;
    currentTranslation = "";
    notifyListeners();

    final systemInstruction = "You are J.A.R.V.I.S., a professional translator. Translate everything the user says from ${sourceLanguage.displayName} to ${targetLanguage.displayName}. Output ONLY the translated text. Be concise and natural.";

    _geminiLiveService.startSession(
      apiKey: "JRV-M7VK-EX4J", 
      systemInstruction: systemInstruction,
    );

    try {
      await _audioCaptureService.init();
      await _audioCaptureService.startCapture();
      _audioCaptureService.audioStream.listen((chunk) {
        if (isRecording && _geminiLiveService.isSessionActive) {
          _geminiLiveService.sendAudioChunk(chunk);
        }
      });
    } catch (e) {
      error = e.toString();
      isRecording = false;
      _geminiLiveService.endSession();
      notifyListeners();
    }
  }

  Future<void> _stopSession() async {
    isRecording = false;
    notifyListeners();
    await _audioCaptureService.stopCapture();
    _geminiLiveService.endSession();
  }
}

class TranslationItem {
  final String originalText;
  final String translatedText;
  TranslationItem({required this.originalText, required this.translatedText});
}
