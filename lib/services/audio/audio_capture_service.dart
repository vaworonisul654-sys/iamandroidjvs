import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioCaptureService {
  static final AudioCaptureService _instance = AudioCaptureService._internal();
  factory AudioCaptureService() => _instance;
  AudioCaptureService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>.broadcast();
  
  bool _isInitialized = false;

  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    await _recorder.openRecorder();
    _isInitialized = true;
  }

  Future<void> startCapture() async {
    if (!_isInitialized) await init();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Microphone permission denied");
    }

    if (_recorder.isRecording) return;

    await _recorder.startRecorder(
      toStream: _audioStreamController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
    );
  }

  Future<void> stopCapture() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
  }

  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close();
    _isInitialized = false;
  }
}
