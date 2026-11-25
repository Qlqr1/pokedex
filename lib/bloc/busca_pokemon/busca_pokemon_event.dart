/// Eventos que a tela envia ao [BuscaPokemonBloc].
sealed class BuscaPokemonEvent {
  const BuscaPokemonEvent();
}

/// O texto do campo de busca mudou (texto vazio = sair da busca).
class BuscaPokemonTextoAlterado extends BuscaPokemonEvent {
  final String texto;

  const BuscaPokemonTextoAlterado(this.texto);
}

/// "Tentar novamente" depois de uma falha ao baixar a lista de nomes.
class BuscaPokemonNovaTentativa extends BuscaPokemonEvent {
  const BuscaPokemonNovaTentativa();
}

/// "Puxar para atualizar" na lista: descarta a lista de nomes já baixada.
class BuscaPokemonAtualizada extends BuscaPokemonEvent {
  const BuscaPokemonAtualizada();
}
