class APIKeys {
  // To provide keys at build time, use:
  // flutter run --dart-define=GEMINI_API_KEY=your_key --dart-define=OPENAI_API_KEY=your_key
  
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY', 
    defaultValue: "YOUR_GEMINI_API_KEY_HERE"
  );
  
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY', 
    defaultValue: "YOUR_OPENAI_API_KEY_HERE"
  );
}
