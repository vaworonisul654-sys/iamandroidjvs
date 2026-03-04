import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../services/network/openai_vision_service.dart';

class PhotoViewModel extends ChangeNotifier {
  CameraController? _controller;
  final OpenAIVisionService _visionService = OpenAIVisionService();
  
  CameraController? get controller => _controller;
  bool _isInitializing = false;
  bool _isAnalyzing = false;
  String _analysisResult = "";
  
  bool get isInitializing => _isInitializing;
  bool get isAnalyzing => _isAnalyzing;
  String get analysisResult => _analysisResult;

  Future<void> initCamera() async {
    if (_controller != null) return;
    
    _isInitializing = true;
    notifyListeners();

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("Камеры не найдены");

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
    } catch (e) {
      debugPrint("Camera init error: $e");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized || _isAnalyzing) return;

    _isAnalyzing = true;
    _analysisResult = "Анализирую...";
    notifyListeners();

    try {
      final image = await _controller!.takePicture();
      final result = await _visionService.analyzeImage(File(image.path));
      _analysisResult = result;
    } catch (e) {
      _analysisResult = "Ошибка: $e";
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    _analysisResult = "";
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
