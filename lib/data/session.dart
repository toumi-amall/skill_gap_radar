// lib/data/session.dart
import 'offers_store.dart';
import 'skills_store.dart';
import 'stats_store.dart';

/// Loads everything for the logged-in user.
Future<void> loadAllData() async {
  pauseTracking = true;
  await loadSkills();
  await loadOffers();
  await loadHistory();
  pauseTracking = false;
}

/// Back to an empty state (logout, guest).
void clearAllData() {
  pauseTracking = true;
  clearSkills();
  offers.value = List.of(sampleOffers);
  scoreHistory.value = [];
  pauseTracking = false;
}
