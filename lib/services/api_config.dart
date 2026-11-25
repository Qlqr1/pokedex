import 'package:flutter/foundation.dart';

/// Endereço da API própria (Flask). Para outro endereço (ex.: aparelho físico),
/// use: flutter run --dart-define=API_URL=http://192.168.0.10:5000
class ApiConfig {
  static const String _definida = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_definida.isNotEmpty) return _definida;
    if (kIsWeb) return 'http://127.0.0.1:5000';
    // 10.0.2.2 é como o emulador Android enxerga o computador.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }
}