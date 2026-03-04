import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../utils/design_system.dart';
import '../viewmodels/memory_view_model.dart';
import '../models/learner_profile.dart';

class MemoryView extends StatelessWidget {
  const MemoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemoryViewModel>();
    final profile = viewModel.profile;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: const BoxDecoration(gradient: DesignSystem.mainGradient)),
          
          // Subtle Ambient Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.emerald.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(profile)),
                SliverToBoxAdapter(child: _buildStatsGrid(profile)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Text(
                      "КОЛЛЕКЦИЯ ОШИБОК",
                      style: TextStyle(
                        color: DesignSystem.emerald,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                if (viewModel.recentMistakes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMistakeCard(viewModel.recentMistakes[index]),
                      childCount: viewModel.recentMistakes.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LearnerProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ПАМЯТЬ J.A.R.V.I.S.",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Прогресс обучения и анализ пробелов",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(LearnerProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _buildStatCard("Словарный запас", profile.vocabularyScore, Icons.menu_book),
          _buildStatCard("Произношение", profile.pronunciationScore, Icons.record_voice_over),
          _buildStatCard("Грамматика", profile.grammarScore, Icons.architecture),
          _buildStatCard("Беглость", profile.fluencyScore, Icons.speed),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: DesignSystem.glassDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: DesignSystem.emerald, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${(value * 100).toInt()}%",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: DesignSystem.emerald,
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMistakeCard(Mistake mistake) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: DesignSystem.glassDecoration(radius: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "ОШИБКА",
                      style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      "${mistake.date.day}.${mistake.date.month}.${mistake.date.year}",
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  mistake.original,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: DesignSystem.emerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: DesignSystem.emerald.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: DesignSystem.emerald, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mistake.correction,
                          style: const TextStyle(color: DesignSystem.emerald, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mistake.explanation,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 60, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            "Ваша память безупречна.\nПродолжайте практиковаться!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
