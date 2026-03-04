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

          // Targeting Overlay
          _buildTargetingOverlay(),

          // Top Info Bar
          Positioned(
            top: 60,
            left: 20,
            child: _buildGlassInfo("РЕЖИМ ВИЗУАЛЬНОГО АНАЛИЗА"),
          ),

          // Analysis Result Card
          if (viewModel.analysisResult.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: _buildResultCard(viewModel),
            ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCaptureButton(viewModel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetingOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.emerald.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            _corner(Alignment.topLeft),
            _corner(Alignment.topRight),
            _corner(Alignment.bottomLeft),
            _corner(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  Widget _corner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0 ? const BorderSide(color: DesignSystem.emerald, width: 3) : BorderSide.none,
            left: alignment.x < 0 ? const BorderSide(color: DesignSystem.emerald, width: 3) : BorderSide.none,
            bottom: alignment.y > 0 ? const BorderSide(color: DesignSystem.emerald, width: 3) : BorderSide.none,
            right: alignment.x > 0 ? const BorderSide(color: DesignSystem.emerald, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInfo(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            text,
            style: const TextStyle(color: DesignSystem.emerald, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(PhotoViewModel viewModel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: DesignSystem.glassDecoration(radius: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: DesignSystem.emerald, size: 20),
                  const SizedBox(width: 8),
                  Text("АНАЛИЗ J.A.R.V.I.S.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () => viewModel.reset(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                viewModel.analysisResult,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(PhotoViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.captureAndAnalyze(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isAnalyzing ? DesignSystem.emerald : Colors.white.withOpacity(0.8),
            ),
            child: viewModel.isAnalyzing
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : null,
          ),
        ),
      ),
    );
  }
}
