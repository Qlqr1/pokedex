/// Eventos que a tela envia ao [ListaPokemonBloc].
sealed class ListaPokemonEvent {
  const ListaPokemonEvent();
}

/// Primeira carga da lista (também usada em "Tentar novamente" após erro).
class ListaPokemonIniciada extends ListaPokemonEvent {
  const ListaPokemonIniciada();
}

/// Pede a próxima página (scroll chegou perto do fim).
class ListaPokemonMaisSolicitado extends ListaPokemonEvent {
  const ListaPokemonMaisSolicitado();
}

/// "Puxar para atualizar": limpa o cache e recarrega do começo.
class ListaPokemonAtualizada extends ListaPokemonEvent {
  const ListaPokemonAtualizada();
}
