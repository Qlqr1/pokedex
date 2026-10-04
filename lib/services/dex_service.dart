import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dex.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class DexService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchPokedexList() async =>
      ((await _get('pokedex?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<PokedexDetail> fetchPokedex(String name) async =>
      PokedexDetail.fromJson(await _get('pokedex/$name'));

  Future<SpeciesDex> fetchSpeciesDex(String speciesName) async =>
      SpeciesDex.fromJson(await _get('pokemon-species/$speciesName'));
}