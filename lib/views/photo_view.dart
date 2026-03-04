import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../viewmodels/photo_view_model.dart';
import '../utils/design_system.dart';

class PhotoView extends StatefulWidget {
  const PhotoView({super.key});

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoViewModel>().initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhotoViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (viewModel.controller != null && viewModel.controller!.value.isInitialized)
            SizedBox.expand(
              child: CameraPreview(viewModel.controller!),
            )
          else
            const Center(child: CircularProgressIndicator(color: DesignSystem.emerald)),

          // Result Card
          if (viewModel.analysisResult.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: Text(viewModel.analysisResult, style: const TextStyle(color: Colors.white)),
              ),
            ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => viewModel.captureAndAnalyze(),
                child: viewModel.isAnalyzing ? const CircularProgressIndicator() : const Text("Capture"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
