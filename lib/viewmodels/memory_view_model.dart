import 'package:flutter/material.dart';
import '../models/learner_profile.dart';

class MemoryViewModel extends ChangeNotifier {
  final ProfileManager _profileManager = ProfileManager();

  LearnerProfile get profile => _profileManager.currentProfile;
  List<Mistake> get recentMistakes => profile.recentMistakes;

  MemoryViewModel() {
    _profileManager.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    notifyListeners();
  }

  Future<void> clearAll() async {
    _profileManager.resetProfile();
  }

  @override
  void dispose() {
    _profileManager.removeListener(_onProfileChanged);
    super.dispose();
  }
}
