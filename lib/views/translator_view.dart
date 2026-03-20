import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/design_system.dart';
import '../viewmodels/translator_view_model.dart';
import '../models/language.dart';

class MainTranslatorView extends StatelessWidget {
  const MainTranslatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TranslatorViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Container(decoration: const BoxDecoration(gradient: DesignSystem.mainGradient)),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, viewModel),
                Expanded(
                  child: _buildTranslationList(viewModel),
                ),
                if (viewModel.currentTranslation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: DesignSystem.glassCard(
                      child: Text(
                        viewModel.currentTranslation,
                        style: const TextStyle(
                          color: DesignSystem.emerald,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                _buildActionArea(viewModel),
                const SizedBox(height: 100), // Tab bar space
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TranslatorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: "ГОЛОС" text
          Text("ГОЛОС", style: DesignSystem.labelSmall),
          // Center: Language selection
          DesignSystem.glassCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _buildLanguageLink(context, viewModel, true),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.swap_horiz, size: 16, color: DesignSystem.emerald),
                  onPressed: () => viewModel.switchLanguages(),
                ),
                _buildLanguageLink(context, viewModel, false),
              ],
            ),
          ),
          // Right side: History and Profile buttons
          Row(
            children: [
              const Icon(Icons.history, color: Colors.white24),
              const SizedBox(width: 12), // Space between history and profile
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView())),
                child: DesignSystem.glassCard(
                  radius: 50, // Circular shape
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

  Widget _buildLanguageLink(BuildContext context, TranslatorViewModel viewModel, bool isSource) {
    final lang = isSource ? viewModel.sourceLanguage : viewModel.targetLanguage;
    return GestureDetector(
      onTap: () => _showLanguageSelector(context, viewModel, isSource),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              lang.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, TranslatorViewModel viewModel, bool isSource) {
    final languages = Language.values;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: DesignSystem.obsidianBlack.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: const Border(top: BorderSide(color: DesignSystem.glassBorder)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                isSource ? "ЯЗЫК ОРИГИНАЛА" : "ЯЗЫК ПЕРЕВОДА",
                style: DesignSystem.labelSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final l = languages[index];
                  final isSelected = (isSource ? viewModel.sourceLanguage : viewModel.targetLanguage) == l;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Text(l.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(l.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(l.nameInRussian, style: TextStyle(color: Colors.white.withOpacity(0.4))),
                    trailing: isSelected ? const Icon(Icons.check, color: DesignSystem.emerald) : null,
                    onTap: () {
                      isSource ? viewModel.setSourceLanguage(l) : viewModel.setTargetLanguage(l);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationList(TranslatorViewModel viewModel) {
    if (viewModel.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_none, size: 48, color: Colors.white10),
            const SizedBox(height: 16),
            Text(
              "Говорите для перевода",
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.history.length,
      itemBuilder: (context, index) {
        final item = viewModel.history[index];
        return _buildChatBubble(item);
      },
    );
  }

  Widget _buildChatBubble(TranslationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              Text(item.originalText, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          DesignSystem.glassCard(
            radius: 20,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                item.translatedText,
                style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(TranslatorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => viewModel.toggleRecording(),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: DesignSystem.emeraldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.emerald.withOpacity(viewModel.isRecording ? 0.4 : 0.2),
                      blurRadius: 25,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  viewModel.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
