import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berry.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class BerryService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchBerryList() async =>
      ((await _get('berry?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<BerryDetail> fetchBerry(String name) async =>
      BerryDetail.fromJson(await _get('berry/$name'));
}