import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/language.dart';

/// Busca os idiomas disponíveis em /language (lista + detalhe de cada um).
class LanguageService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<LanguageInfo>> fetchLanguages() async {
    final results = (await _get('language?limit=100'))['results'] as List;
    final list = await Future.wait(results.map((e) async {
      final parts =
          (e['url'] as String).split('/').where((p) => p.isNotEmpty).toList();
      return LanguageInfo.fromJson(await _get('language/${parts.last}'));
    }));
    list.sort((a, b) => a.englishName.compareTo(b.englishName));
    return list;
  }
}
