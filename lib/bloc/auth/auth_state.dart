/// Estados do login (Inicial, Carregando, Sucesso = Autenticado, Erro, mais
/// Deslogado, para "ninguém logado").
sealed class AuthState {
  const AuthState();
}

/// O app acabou de abrir e ainda não leu a sessão salva.
class AuthInicial extends AuthState {
  const AuthInicial();
}

/// Entrando ou criando a conta.
class AuthCarregando extends AuthState {
  const AuthCarregando();
}

class AuthAutenticado extends AuthState {
  final String usuario;

  const AuthAutenticado(this.usuario);
}

class AuthDeslogado extends AuthState {
  const AuthDeslogado();
}

class AuthErro extends AuthState {
  final String mensagem;

  const AuthErro(this.mensagem);
}