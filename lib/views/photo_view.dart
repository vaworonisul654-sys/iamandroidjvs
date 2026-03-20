import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../viewmodels/photo_view_model.dart';
import '../utils/design_system.dart';
import 'profile_view.dart';

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
            Container(color: DesignSystem.obsidianBlack),

          // HUD Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DesignSystem.glassCard(
                        radius: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam, color: DesignSystem.emerald, size: 14),
                            const SizedBox(width: 8),
                            Text("LIVE ANALYSIS", style: DesignSystem.labelSmall),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView())),
                        child: DesignSystem.glassCard(
                          radius: 50,
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (viewModel.analysisResult.isNotEmpty)
                    _buildResultCard(viewModel),
                  const SizedBox(height: 24),
                  _buildControls(viewModel),
                  const SizedBox(height: 100), // Tab bar space
                ],
              ),
            ),
          ),
          
          // Targeting frames
          if (viewModel.analysisResult.isEmpty)
             _buildTargetingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTargetingOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10, width: 1),
          borderRadius: BorderRadius.circular(30),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0 ? const BorderSide(color: DesignSystem.emerald, width: 4) : BorderSide.none,
            left: alignment.x < 0 ? const BorderSide(color: DesignSystem.emerald, width: 4) : BorderSide.none,
            bottom: alignment.y > 0 ? const BorderSide(color: DesignSystem.emerald, width: 4) : BorderSide.none,
            right: alignment.x > 0 ? const BorderSide(color: DesignSystem.emerald, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(PhotoViewModel viewModel) {
    return DesignSystem.glassCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: DesignSystem.emerald, size: 18),
              const SizedBox(width: 8),
              Text("J.A.R.V.I.S. VISION", style: DesignSystem.labelSmall),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, color: Colors.white24, size: 20),
                onPressed: () => viewModel.reset(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.analysisResult,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(PhotoViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSideButton(
          icon: Icons.photo_library_rounded,
          onTap: () => viewModel.pickFromGallery(),
        ),
        _buildCaptureButton(viewModel),
        _buildSideButton(
          icon: Icons.flash_on_rounded, // Placeholder for flash toggle
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSideButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: DesignSystem.glassCard(
        radius: 50,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCaptureButton(PhotoViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.captureAndAnalyze(),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: viewModel.isAnalyzing
                ? const Center(child: CircularProgressIndicator(color: DesignSystem.emerald, strokeWidth: 3))
                : const Icon(Icons.camera_alt, color: Colors.black, size: 32),
          ),
        ),
      ),
    );
  }
}
