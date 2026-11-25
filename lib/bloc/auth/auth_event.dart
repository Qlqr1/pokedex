sealed class AuthEvent {
  const AuthEvent();
}

/// Ao abrir o app: recupera a sessão salva, se houver.
class AuthIniciada extends AuthEvent {
  const AuthIniciada();
}

class AuthEntrarSolicitado extends AuthEvent {
  final String usuario;
  final String senha;

  const AuthEntrarSolicitado(this.usuario, this.senha);
}

class AuthRegistrarSolicitado extends AuthEvent {
  final String usuario;
  final String senha;

  const AuthRegistrarSolicitado(this.usuario, this.senha);
}

class AuthSairSolicitado extends AuthEvent {
  const AuthSairSolicitado();
}