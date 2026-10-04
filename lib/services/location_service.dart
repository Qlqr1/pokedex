import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class LocationService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchRegions() async =>
      ((await _get('region?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<Region> fetchRegion(String name) async =>
      Region.fromJson(await _get('region/$name'));

  Future<LocationInfo> fetchLocation(String name) async =>
      LocationInfo.fromJson(await _get('location/$name'));

  Future<LocationArea> fetchLocationArea(String name) async =>
      LocationArea.fromJson(await _get('location-area/$name'));

  Future<List<NamedRef>> fetchPalParkAreas() async =>
      ((await _get('pal-park-area?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<PalParkArea> fetchPalParkArea(String name) async =>
      PalParkArea.fromJson(await _get('pal-park-area/$name'));

  Future<List<PokemonAreaEncounter>> fetchPokemonEncounters(int pokemonId) async =>
      ((await _get('pokemon/$pokemonId/encounters')) as List)
          .map((e) => PokemonAreaEncounter.fromJson(e))
          .toList();
}