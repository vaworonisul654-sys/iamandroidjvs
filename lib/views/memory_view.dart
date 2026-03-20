import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Container(decoration: const BoxDecoration(gradient: DesignSystem.mainGradient)),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(profile)),
                SliverToBoxAdapter(child: _buildStatsGrid(profile)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Text("КОЛЛЕКЦИЯ ОШИБОК", style: DesignSystem.labelSmall),
                  ),
                ),
                if (viewModel.recentMistakes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMistakeCard(viewModel.recentMistakes[index]),
                        childCount: viewModel.recentMistakes.length,
                      ),
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

  Widget _buildHeader(BuildContext context, LearnerProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ПАМЯТЬ J.A.R.V.I.S.", style: DesignSystem.titleLarge),
              const SizedBox(height: 4),
              Text(
                "Прогресс обучения и анализ пробелов",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              ),
            ],
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
        childAspectRatio: 1.5,
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
    return DesignSystem.glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: DesignSystem.emerald, size: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${(value * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title.toUpperCase(),
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeCard(Mistake mistake) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DesignSystem.glassCard(
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                const SizedBox(width: 8),
                const Text("ОШИБКА", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  "${mistake.date.day}.${mistake.date.month}.${mistake.date.year}",
                  style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mistake.original,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignSystem.emerald.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: DesignSystem.emerald, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mistake.correction,
                      style: const TextStyle(color: DesignSystem.emerald, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            if (mistake.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                mistake.explanation,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            "Памятка пуста.\nПрактикуйтесь больше!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
