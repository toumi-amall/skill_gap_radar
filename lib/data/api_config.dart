// lib/data/api_config.dart
import 'package:flutter/foundation.dart';

/// Android emulator reaches your PC through 10.0.2.2; Chrome uses localhost.
String get apiBase =>
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
    ? 'http://10.0.2.2:3000/api'
    : 'http://localhost:3000/api';
