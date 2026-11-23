// lib/data/api_client.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_store.dart';

/// Calls the API with the user's token.
/// Returns null for guests, or when the API is offline.
Future<http.Response?> api(
  String method,
  String path, [
  Map<String, dynamic>? body,
]) async {
  if (!isLoggedIn) return null;
  try {
    final uri = Uri.parse('$apiBase$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
    switch (method) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return await http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(uri, headers: headers);
    }
  } catch (_) {
    // API offline: the change stays in memory only
  }
  return null;
}
