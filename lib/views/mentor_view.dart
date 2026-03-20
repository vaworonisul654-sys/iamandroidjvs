import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/design_system.dart';
import '../viewmodels/mentor_view_model.dart';
import 'profile_view.dart';

class MentorView extends StatefulWidget {
  const MentorView({super.key});

  @override
  State<MentorView> createState() => _MentorViewState();
}

class _MentorViewState extends State<MentorView> with SingleTickerProviderStateMixin {
  late AnimationController _orbController;
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MentorViewModel>().init();
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MentorViewModel>();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: const BoxDecoration(gradient: DesignSystem.mainGradient)),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(viewModel),
                
                if (!viewModel.isActivated)
                  Expanded(child: _buildLockedState(viewModel))
                else ...[
                  const Spacer(),
                  const Text("JARVIS CORE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4, color: DesignSystem.emerald)),
                  const Spacer(),
                  _buildOrb(viewModel),
                  const Spacer(),
                  _buildResponseText(viewModel),
                  const Spacer(),
                  const SizedBox(height: 100),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MentorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("MENTOR", style: DesignSystem.labelSmall),
          Row(
            children: [
              if (viewModel.isActivated)
                DesignSystem.glassCard(
                  radius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: DesignSystem.emerald, size: 14),
                      SizedBox(width: 8),
                      Text("ACTIVE", style: TextStyle(color: DesignSystem.emerald, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
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
        ],
      ),
    );
  }

  Widget _buildLockedState(MentorViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: DesignSystem.glassCard(
          radius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: DesignSystem.emerald, size: 48),
              const SizedBox(height: 24),
              const Text(
                "Jarvis Core Заблокирован",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Для активации AI-наставника введите ваш лицензионный ключ.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _showActivationDialog(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.emerald,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("АКТИВИРОВАТЬ", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivationDialog(MentorViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.obsidianBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), border: Border.all(color: DesignSystem.glassBorder)),
        title: const Text("Активация", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _keyController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "JRV-XXXX-XXXX",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: DesignSystem.emerald)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена", style: TextStyle(color: Colors.white24)),
          ),
          TextButton(
            onPressed: () async {
              final success = await viewModel.activate(_keyController.text);
              if (success && mounted) Navigator.pop(context);
            },
            child: const Text("ОК", style: TextStyle(color: DesignSystem.emerald)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(MentorViewModel viewModel) {
    bool isActive = viewModel.state != MentorState.idle;
    return GestureDetector(
      onTap: () => isActive ? viewModel.stopSession() : viewModel.startSession(),
      child: AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DesignSystem.emerald.withOpacity(isActive ? 0.3 + (_orbController.value * 0.2) : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: DesignSystem.emeraldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.emerald.withOpacity(isActive ? 0.5 : 0.2),
                      blurRadius: isActive ? 30 + (_orbController.value * 20) : 10,
                      spreadRadius: isActive ? 5 : 0,
                    )
                  ],
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 48),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponseText(MentorViewModel viewModel) {
    String text = "Нажмите на ядро, чтобы начать";
    if (viewModel.state == MentorState.connecting) text = "Подключение...";
    if (viewModel.state == MentorState.active) text = "Я слушаю...";
    if (viewModel.currentResponse.isNotEmpty) text = viewModel.currentResponse;
    if (viewModel.errorMessage != null) text = viewModel.errorMessage!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
      ),
    );
  }
}
