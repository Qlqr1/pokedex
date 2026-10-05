import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

/// Pode migrar este método para o PokeApiService se preferir.
class CurrencyService {
  /// Caminho do endpoint. Se a PokéAPI usar outro nome, ajuste só aqui.
  static const _path = 'currency?limit=100';
  static const _base = 'https://pokeapi.co/api/v2';

  Future<List<Currency>> fetchCurrencies() async {
    final res = await http.get(Uri.parse('$_base/$_path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar moedas (${res.statusCode})');
    }
    final list = (jsonDecode(res.body)['results'] as List)
        .map((e) => Currency.fromJson(e))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return list;
  }
}