// lib/data/skills_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// The user's skills (names). Any screen can listen to it.
final ValueNotifier<List<String>> mySkills = ValueNotifier<List<String>>([]);

/// Level of each skill: 1 = beginner, 2 = intermediate, 3 = advanced.
final Map<String, int> _levels = {};

const levelNames = {1: 'Beginner', 2: 'Intermediate', 3: 'Advanced'};

int levelOf(String name) => _levels[name.toLowerCase()] ?? 2;

Future<void> loadSkills() async {
  final r = await api('GET', '/skills');
  if (r == null || r.statusCode != 200) return;

  final data = jsonDecode(r.body) as List;
  _levels.clear();
  final names = <String>[];
  for (final e in data) {
    final name = e is Map ? e['name'] as String : e as String;
    final level = e is Map ? (e['level'] as num?)?.toInt() ?? 2 : 2;
    names.add(name);
    _levels[name.toLowerCase()] = level;
  }
  mySkills.value = names;
}

void clearSkills() {
  _levels.clear();
  mySkills.value = [];
}

void addSkill(String name, [int level = 2]) {
  final skill = name.trim();
  if (skill.isEmpty) return;

  final exists = mySkills.value.any(
    (s) => s.toLowerCase() == skill.toLowerCase(),
  );
  if (exists) return;

  _levels[skill.toLowerCase()] = level;
  mySkills.value = [...mySkills.value, skill];
  api('POST', '/skills', {'name': skill, 'level': level});
}

void removeSkill(String name) {
  _levels.remove(name.toLowerCase());
  mySkills.value = mySkills.value.where((s) => s != name).toList();
  api('DELETE', '/skills/${Uri.encodeComponent(name)}');
}

void setSkillLevel(String name, int level) {
  _levels[name.toLowerCase()] = level;
  // new list instance so every screen listening to mySkills rebuilds
  mySkills.value = [...mySkills.value];
  api('PUT', '/skills/${Uri.encodeComponent(name)}', {'level': level});
}
