import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioCaptureService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>.broadcast();
  
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  Future<void> init() async {
    await _recorder.openRecorder();
  }

  Future<void> startCapture() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Microphone permission denied");
    }

    await _recorder.startRecorder(
      toStream: _audioStreamController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
    );
  }

  Future<void> stopCapture() async {
    await _recorder.stopRecorder();
  }

  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close();
  }
}
