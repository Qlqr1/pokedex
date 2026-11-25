/// Resposta de /login e /registro: o token e o nome do usuário.
class Sessao {
  final String token;
  final String usuario;

  const Sessao({required this.token, required this.usuario});

  factory Sessao.fromJson(Map<String, dynamic> json) {
    return Sessao(
      token: json['token'] as String,
      usuario: json['usuario'] as String,
    );
  }
}