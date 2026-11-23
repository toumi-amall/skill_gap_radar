// lib/data/stats_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'offers_store.dart';
import 'skills_store.dart';

/// Average match score over time (oldest first, 30 points max).
final ValueNotifier<List<int>> scoreHistory = ValueNotifier<List<int>>([]);

/// True while data is loading or cleared, so no fake points are recorded.
bool pauseTracking = false;

Future<void> loadHistory() async {
  final r = await api('GET', '/snapshots');
  if (r == null || r.statusCode != 200) return;
  scoreHistory.value = (jsonDecode(r.body) as List)
      .map((e) => (e as num).toInt())
      .toList();
}

/// Records a new point whenever skills or offers change the average score.
void startTracking() {
  void record() {
    if (pauseTracking) return;
    final avg = averageScore(offers.value, mySkills.value);
    final h = scoreHistory.value;
    if (h.isNotEmpty && h.last == avg) return;

    final kept = h.length >= 30 ? h.sublist(h.length - 29) : h;
    scoreHistory.value = [...kept, avg];
    api('POST', '/snapshots', {'score': avg});
  }

  mySkills.addListener(record);
  offers.addListener(record);
  record(); // first point
}
