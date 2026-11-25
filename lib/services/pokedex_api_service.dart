import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/favorito.dart';
import '../models/sessao.dart';
import 'api_config.dart';

/// Erro devolvido pela API própria, ou falha de conexão com ela.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Camada HTTP da API própria (Flask). Só fala com a rede: quem guarda o
/// token e decide o que fazer com os dados são os repositories.
class PokedexApiService {
  final http.Client _client;

  PokedexApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Sessao> registrar(String usuario, String senha) async {
    final dados = await _enviar(
      'POST',
      '/registro',
      corpo: {'usuario': usuario, 'senha': senha},
    );
    return Sessao.fromJson(dados as Map<String, dynamic>);
  }

  Future<Sessao> entrar(String usuario, String senha) async {
    final dados = await _enviar(
      'POST',
      '/login',
      corpo: {'usuario': usuario, 'senha': senha},
    );
    return Sessao.fromJson(dados as Map<String, dynamic>);
  }

  Future<void> sair(String token) => _enviar('POST', '/logout', token: token);

  Future<List<Favorito>> listarFavoritos(String token) async {
    final dados = await _enviar('GET', '/favoritos', token: token);
    return (dados as List<dynamic>)
        .map((e) => Favorito.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> adicionarFavorito(String token, Favorito favorito) => _enviar(
    'POST',
    '/favoritos',
    token: token,
    corpo: {'pokemon_id': favorito.pokemonId, 'nome': favorito.nome},
  );

  Future<void> removerFavorito(String token, int pokemonId) =>
      _enviar('DELETE', '/favoritos/$pokemonId', token: token);

  void dispose() => _client.close();

  Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    String? token,
    Map<String, dynamic>? corpo,
  }) async {
    final requisicao = http.Request(
      metodo,
      Uri.parse('${ApiConfig.baseUrl}$caminho'),
    );
    if (token != null) requisicao.headers['Authorization'] = 'Bearer $token';
    if (corpo != null) {
      requisicao.headers['Content-Type'] = 'application/json';
      requisicao.body = jsonEncode(corpo);
    }

    final http.Response resposta;
    try {
      final stream = await _client
          .send(requisicao)
          .timeout(const Duration(seconds: 10));
      resposta = await http.Response.fromStream(stream);
    } on Exception {
      throw const ApiException(
        'Não foi possível conectar ao servidor da Pokédex. '
        'Verifique se a API está ligada.',
      );
    }

    final texto = utf8.decode(resposta.bodyBytes);

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return texto.isEmpty ? null : jsonDecode(texto);
    }

    var mensagem = 'Erro ${resposta.statusCode} na API.';
    try {
      final dados = jsonDecode(texto);
      if (dados is Map && dados['erro'] is String) {
        mensagem = dados['erro'] as String;
      }
    } catch (_) {
      // Corpo sem JSON: fica a mensagem genérica.
    }
    throw ApiException(mensagem, statusCode: resposta.statusCode);
  }
}