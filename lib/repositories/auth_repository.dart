import 'package:shared_preferences/shared_preferences.dart';

import '../models/sessao.dart';
import '../services/pokedex_api_service.dart';

/// Login, cadastro e a sessão salva no aparelho (para continuar logado ao
/// reabrir o app).
class AuthRepository {
  static const String _chaveToken = 'sessao_token';
  static const String _chaveUsuario = 'sessao_usuario';

  final PokedexApiService _api;
  Sessao? _sessao;

  AuthRepository({required PokedexApiService api}) : _api = api;

  /// Token da sessão atual (null = ninguém logado).
  String? get token => _sessao?.token;

  /// Lê a sessão salva. Não confirma com o servidor: se o token já não valer,
  /// o primeiro pedido de favoritos responde 401.
  Future<Sessao?> restaurar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_chaveToken);
    final usuario = prefs.getString(_chaveUsuario);
    if (token == null || usuario == null) return null;
    return _sessao = Sessao(token: token, usuario: usuario);
  }

  Future<Sessao> entrar(String usuario, String senha) async =>
      _guardar(await _api.entrar(usuario, senha));

  Future<Sessao> registrar(String usuario, String senha) async =>
      _guardar(await _api.registrar(usuario, senha));

  Future<void> sair() async {
    final token = _sessao?.token;
    _sessao = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
    await prefs.remove(_chaveUsuario);
    if (token != null) {
      try {
        await _api.sair(token);
      } catch (_) {
        // Servidor fora do ar: a sessão local já foi encerrada.
      }
    }
  }

  Future<Sessao> _guardar(Sessao sessao) async {
    _sessao = sessao;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, sessao.token);
    await prefs.setString(_chaveUsuario, sessao.usuario);
    return sessao;
  }
}