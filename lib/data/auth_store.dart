// lib/data/auth_store.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

String? authToken;
String userName = '';
bool get isLoggedIn => authToken != null;

Future<void> loadSession() async {
  final p = await SharedPreferences.getInstance();
  authToken = p.getString('token');
  userName = p.getString('name') ?? '';
}

Future<void> logout() async {
  authToken = null;
  userName = '';
  final p = await SharedPreferences.getInstance();
  await p.remove('token');
  await p.remove('name');
}

/// Returns an error message, or null on success.
Future<String?> login(String email, String password) =>
    _auth('/auth/login', {'email': email.trim(), 'password': password});

Future<String?> register(String name, String email, String password) => _auth(
  '/auth/register',
  {'name': name.trim(), 'email': email.trim(), 'password': password},
);

Future<String?> _auth(String path, Map<String, String> body) async {
  try {
    final r = await http.post(
      Uri.parse('$apiBase$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode == 200 || r.statusCode == 201) {
      authToken = data['token'] as String;
      userName = (data['name'] ?? '') as String;
      final p = await SharedPreferences.getInstance();
      await p.setString('token', authToken!);
      await p.setString('name', userName);
      return null;
    }
    return (data['error'] ?? 'Something went wrong') as String;
  } catch (_) {
    return 'Cannot reach the server. Is the API running?';
  }
}
