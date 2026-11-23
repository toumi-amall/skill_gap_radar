import 'dart:convert';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'skills_store.dart';

class Offer {
  final String title;
  final String company;
  final List<String> required;
  const Offer(this.title, this.company, this.required);

  Map<String, dynamic> toJson() => {
    'title': title,
    'company': company,
    'required': required,
  };

  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
    (j['title'] ?? '') as String,
    (j['company'] ?? '') as String,
    List<String>.from(j['required'] as List),
  );
}

/// Offers saved by the user. Filled from the API at startup.
/// Sample offers: what guests see, and what new accounts start with.
const sampleOffers = [
  Offer('Data Analyst Intern', 'Company A', [
    'SQL',
    'Power BI',
    'Python',
    'Git',
  ]),
  Offer('Flutter Developer', 'Company B', ['Flutter', 'Dart', 'Git', 'Docker']),
  Offer('Full Stack Developer', 'Company C', [
    'React',
    'Node.js',
    'Docker',
    'Git',
  ]),
  Offer('BI Developer', 'Company D', ['SQL', 'Power BI', 'Python', 'Docker']),
];

/// Offers on screen. Guests see the samples, accounts load theirs from the API.
final ValueNotifier<List<Offer>> offers = ValueNotifier<List<Offer>>(
  List.of(sampleOffers),
);

Future<void> loadOffers() async {
  final r = await api('GET', '/offers');
  if (r == null || r.statusCode != 200) return;
  offers.value = (jsonDecode(r.body) as List)
      .map((e) => Offer.fromJson(e as Map<String, dynamic>))
      .toList();
}

void addOffer(Offer o) {
  offers.value = [o, ...offers.value];
  api('POST', '/offers', o.toJson());
}

bool hasSkill(List<String> skills, String s) =>
    skills.any((m) => m.toLowerCase() == s.toLowerCase());

/// Match score (0-100) between one offer and the user's skills.
/// Level an offer is assumed to expect (2 = intermediate).
const kRequiredLevel = 2;

/// Match score (0-100): a skill at beginner level counts half,
/// intermediate or advanced counts fully.
int matchScore(Offer o, List<String> skills) {
  if (o.required.isEmpty) return 0;
  var points = 0.0;
  for (final r in o.required) {
    if (hasSkill(skills, r)) {
      points += min(levelOf(r), kRequiredLevel) / kRequiredLevel;
    }
  }
  return (points * 100 / o.required.length).round();
}

int averageScore(List<Offer> list, List<String> skills) {
  if (list.isEmpty) return 0;
  final sum = list.fold<int>(0, (a, o) => a + matchScore(o, skills));
  return (sum / list.length).round();
}

/// How many offers require each skill.
Map<String, int> demand(List<Offer> list) {
  final m = <String, int>{};
  for (final o in list) {
    for (final r in o.required) {
      m[r] = (m[r] ?? 0) + 1;
    }
  }
  return m;
}

/// Skills the user lacks, most demanded first.
List<MapEntry<String, int>> topMissing(List<Offer> list, List<String> skills) {
  final out =
      demand(list).entries.where((e) => !hasSkill(skills, e.key)).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  return out;
}

/// Skills the app knows how to detect in an offer text.
const knownSkills = [
  'Flutter',
  'Dart',
  'Python',
  'SQL',
  'Power BI',
  'Node.js',
  'React',
  'Git',
  'Docker',
  'Django',
  'Java',
  'JavaScript',
  'TypeScript',
  'Kotlin',
  'PHP',
  'Laravel',
  'Angular',
  'Vue',
  'MongoDB',
  'PostgreSQL',
  'Excel',
  'Tableau',
  'Spark',
  'Kubernetes',
  'AWS',
  'Azure',
  'CI/CD',
  'Linux',
  'Figma',
  'Scrum',
];

/// Finds the known skills mentioned in a text (whole words only).
List<String> extractSkills(String text) {
  final t = text.toLowerCase();
  return knownSkills.where((s) {
    final pattern = RegExp(
      '(?<![a-z0-9])${RegExp.escape(s.toLowerCase())}(?![a-z0-9])',
    );
    return pattern.hasMatch(t);
  }).toList();
}
