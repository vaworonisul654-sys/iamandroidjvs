import 'package:flutter/material.dart';

class TranslatorViewModel extends ChangeNotifier {
  bool isRecording = false;
  List<TranslationItem> history = [];

  void toggleRecording() {
    isRecording = !isRecording;
    if (!isRecording) {
      // Mock translation for now
      history.insert(0, TranslationItem(
        originalText: "Привет, как дела?", 
        translatedText: "Hello, how are you?"
      ));
    }
    notifyListeners();
  }
}

class TranslationItem {
  final String originalText;
  final String translatedText;
  TranslationItem({required this.originalText, required this.translatedText});
}
