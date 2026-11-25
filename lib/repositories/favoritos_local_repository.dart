import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorito.dart';
import 'favoritos_repository.dart';

/// Guarda os favoritos como uma lista JSON no shared_preferences.
class FavoritosLocalRepository implements FavoritosRepository {
  static const String _chave = 'favoritos';

  @override
  Future<List<Favorito>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null) return [];

    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((e) => Favorito.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Dado salvo corrompido: começa de novo em vez de travar a tela.
      return [];
    }
  }

  @override
  Future<void> adicionar(Favorito favorito) async {
    final atuais = await listar();
    if (atuais.any((f) => f.pokemonId == favorito.pokemonId)) return;
    await _salvar([...atuais, favorito]);
  }

  @override
  Future<void> remover(int pokemonId) async {
    final atuais = await listar();
    await _salvar(atuais.where((f) => f.pokemonId != pokemonId).toList());
  }

  Future<void> _salvar(List<Favorito> favoritos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode(favoritos.map((f) => f.toJson()).toList()),
    );
  }
}