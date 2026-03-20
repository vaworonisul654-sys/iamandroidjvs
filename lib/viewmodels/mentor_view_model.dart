import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/learner_profile.dart';
import '../services/audio/audio_capture_service.dart';
import '../services/network/gemini_live_service.dart';
import '../services/network/license_service.dart';
import '../services/tts/tts_service.dart';
import '../services/mentor/mentor_service.dart';

enum MentorState { idle, connecting, active, speaking, error }

class MentorViewModel extends ChangeNotifier {
  MentorState _state = MentorState.idle;
  String _currentResponse = "";
  double _audioLevel = 0;
  String? _errorMessage;
  
  // Services
  final GeminiLiveService _geminiService = GeminiLiveService();
  final AudioCaptureService _audioCaptureService = AudioCaptureService();
  final TTSService _ttsService = TTSService();
  final MentorService _mentorService = MentorService();
  final ProfileManager _profileManager = ProfileManager();
  final LicenseService _licenseService = LicenseService();

  MentorState get state => _state;
  String get currentResponse => _currentResponse;
  double get audioLevel => _audioLevel;
  String? get errorMessage => _errorMessage;
  bool get isActivated => _licenseService.isActivated;

  MentorViewModel() {
    _setupCallbacks();
  }

  Future<void> init() async {
    await _profileManager.init();
    await _audioCaptureService.init();
    await _ttsService.init();
    await _licenseService.init();
    notifyListeners();
  }

  void _setupCallbacks() {
    _geminiService.onTranslatedText = (text) {
      _currentResponse += text;
      _state = MentorState.speaking;
      notifyListeners();
    };

    _geminiService.onAudioData = (audio) {
      _ttsService.playGeminiAudio(Uint8List.fromList(audio));
      _state = MentorState.speaking;
      notifyListeners();
    };

    _geminiService.onTurnComplete = () {
      if (_currentResponse.isNotEmpty) {
        _parseAndProcessTags(_currentResponse);
        _currentResponse = "";
      }
      _state = MentorState.active;
      notifyListeners();
    };

    _geminiService.onSetupComplete = () {
      _geminiService.sendTextMessage("Начни."); // Trigger first response
    };

    _geminiService.onError = (err) {
      _errorMessage = err;
      _state = MentorState.error;
      notifyListeners();
    };
  }

  Future<bool> activate(String key) async {
    final success = await _licenseService.checkStatus(key);
    notifyListeners();
    return success;
  }

  Future<void> startSession() async {
    if (!isActivated) {
      _errorMessage = "Требуется активация в Личном Кабинете";
      notifyListeners();
      return;
    }

    _state = MentorState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final key = _licenseService.currentKey!;
      final instruction = _mentorService.getSystemInstruction(_profileManager.currentProfile);
      
      _geminiService.startSession(
        apiKey: key,
        systemInstruction: instruction,
      );

      // Start audio capture stream
      await _audioCaptureService.startCapture();
      _audioCaptureService.audioStream.listen((chunk) {
        if (_geminiService.isSessionActive && !_ttsService.isSpeaking) {
          _geminiService.sendAudioChunk(chunk);
        }
      });

    } catch (e) {
      _errorMessage = e.toString();
      _state = MentorState.error;
      notifyListeners();
    }
  }

  void stopSession() {
    _geminiService.endSession();
    _audioCaptureService.stopCapture();
    _ttsService.stop();
    _state = MentorState.idle;
    _currentResponse = "";
    notifyListeners();
  }

  void _parseAndProcessTags(String text) {
    // 1. Parse Mistakes [MISTAKE: original | correction | explanation]
    final mistakeRegex = RegExp(r'\[MISTAKE\s*:\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\]');
    final mistakeMatches = mistakeRegex.allMatches(text);
    for (var match in mistakeMatches) {
      _profileManager.addMistake(match.group(1)!, match.group(2)!, match.group(3)!);
    }
    
    // 2. Parse Program Update [PROGRAM_UPDATE: text]
    final programRegex = RegExp(r'\[PROGRAM_UPDATE\s*:\s*(.*?)\s*\]', dotAll: true);
    final programMatch = programRegex.firstMatch(text);
    if (programMatch != null) {
      _profileManager.currentProfile.teachingProgram = programMatch.group(1);
      _profileManager.currentProfile.isInitialAssessmentComplete = true;
      _profileManager.save();
    }
  }

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    _audioCaptureService.dispose();
    _ttsService.dispose();
    _geminiService.endSession();
    super.dispose();
  }
}
