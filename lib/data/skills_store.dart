// lib/data/skills_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// The user's skills. Any screen can listen to it.
final ValueNotifier<List<String>> mySkills = ValueNotifier<List<String>>([]);

const _json = {'Content-Type': 'application/json'};

Future<void> loadSkills() async {
  try {
    final r = await http.get(Uri.parse('$apiBase/skills'));
    if (r.statusCode == 200) {
      mySkills.value = List<String>.from(jsonDecode(r.body) as List);
    }
  } catch (_) {
    // API offline: keep whatever is in memory
  }
}

void addSkill(String name) {
  final skill = name.trim();
  if (skill.isEmpty) return;

  final exists = mySkills.value.any(
    (s) => s.toLowerCase() == skill.toLowerCase(),
  );
  if (exists) return;

  mySkills.value = [...mySkills.value, skill];
  _send(
    () => http.post(
      Uri.parse('$apiBase/skills'),
      headers: _json,
      body: jsonEncode({'name': skill}),
    ),
  );
}

void removeSkill(String name) {
  mySkills.value = mySkills.value.where((s) => s != name).toList();
  _send(
    () =>
        http.delete(Uri.parse('$apiBase/skills/${Uri.encodeComponent(name)}')),
  );
}

Future<void> _send(Future<http.Response> Function() request) async {
  try {
    await request();
  } catch (_) {
    // API offline: the change stays in memory only
  }
}
