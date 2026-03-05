import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/design_system.dart';
import '../viewmodels/translator_view_model.dart';

class MainTranslatorView extends StatelessWidget {
  const MainTranslatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TranslatorViewModel>();

    return Scaffold(
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
          Text("ГОЛОС", style: DesignSystem.labelSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: DesignSystem.glassDecoration(radius: 20),
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
          const Icon(Icons.history, color: Colors.white24),
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
        child: Text(
          lang,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, TranslatorViewModel viewModel, bool isSource) {
    final languages = ["RU", "EN", "DE", "FR", "JP", "ES", "IT", "ZH"];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: DesignSystem.glassDecoration(radius: 30).copyWith(
          color: DesignSystem.background.withOpacity(0.9),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              isSource ? "ВЫБЕРИТЕ ЯЗЫК ОРИГИНАЛА" : "ВЫБЕРИТЕ ЯЗЫК ПЕРЕВОДА",
              style: DesignSystem.labelSmall,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final l = languages[index];
                final isSelected = (isSource ? viewModel.sourceLanguage : viewModel.targetLanguage) == l;
                return GestureDetector(
                  onTap: () {
                    isSource ? viewModel.setSourceLanguage(l) : viewModel.setTargetLanguage(l);
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? DesignSystem.emerald.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? DesignSystem.emerald : Colors.white10),
                    ),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? DesignSystem.emerald : Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
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
            Icon(Icons.waves, size: 48, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              "Говорите, чтобы начать перевод",
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.originalText, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: DesignSystem.glassDecoration(radius: 16),
            child: Text(
              item.translatedText,
              style: const TextStyle(color: DesignSystem.emerald, fontSize: 18, fontWeight: FontWeight.bold),
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
            if (viewModel.isRecording)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  "Слушаю...",
                  style: TextStyle(color: DesignSystem.emerald, fontWeight: FontWeight.bold),
                ),
              ),
            GestureDetector(
              onTap: () => viewModel.toggleRecording(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: viewModel.isRecording 
                    ? Colors.red.withOpacity(0.05) 
                    : DesignSystem.emerald.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: viewModel.isRecording 
                        ? Colors.red.withOpacity(0.2) 
                        : DesignSystem.emerald.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (viewModel.isRecording ? Colors.red : DesignSystem.emerald).withOpacity(0.8),
                          (viewModel.isRecording ? Colors.red : DesignSystem.emerald).withOpacity(0.3),
                        ],
                      ),
                      border: Border.all(
                        color: (viewModel.isRecording ? Colors.red : DesignSystem.emerald).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      viewModel.isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
