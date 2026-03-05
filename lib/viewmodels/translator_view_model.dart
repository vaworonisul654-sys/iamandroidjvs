import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/audio/audio_capture_service.dart';
import '../services/network/translation_service.dart';

class TranslatorViewModel extends ChangeNotifier {
  bool isRecording = false;
  List<TranslationItem> history = [];
  
  // Language State
  String sourceLanguage = "RU";
  String targetLanguage = "EN";
  
  // Services
  final AudioCaptureService _audioCaptureService = AudioCaptureService();
  final TranslationService _translationService = TranslationService();
  
  List<int> _recordedChunks = [];

  void setSourceLanguage(String lang) {
    sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
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
    if (isRecording) {
      await _stopAndTranslate();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    isRecording = true;
    _recordedChunks.clear();
    notifyListeners();
    
    await _audioCaptureService.init();
    await _audioCaptureService.startCapture();
    _audioCaptureService.audioStream.listen((chunk) {
      if (isRecording) {
        _recordedChunks.addAll(chunk);
      }
    });
  }

  Future<void> _stopAndTranslate() async {
    isRecording = false;
    notifyListeners();
    
    await _audioCaptureService.stopCapture();
    
    if (_recordedChunks.isNotEmpty) {
      final audioData = Uint8List.fromList(_recordedChunks);
      final result = await _translationService.translateSpeech(
        audioData: audioData,
        sourceLang: sourceLanguage,
        targetLang: targetLanguage,
      );
      
      history.insert(0, TranslationItem(
        originalText: result.original,
        translatedText: result.translated,
      ));
      notifyListeners();
    }
  }
}

class TranslationItem {
  final String originalText;
  final String translatedText;
  TranslationItem({required this.originalText, required this.translatedText});
}
