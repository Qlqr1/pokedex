/// Um Pokémon favoritado. Os nomes dos campos no JSON são os mesmos da API
/// Flask (pokemon_id, nome, nota), para reaproveitar o model depois.
class Favorito {
  final int pokemonId;
  final String nome;
  final String nota;

  const Favorito({
    required this.pokemonId,
    required this.nome,
    this.nota = '',
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      pokemonId: (json['pokemon_id'] as num).toInt(),
      nome: json['nome'] as String,
      nota: (json['nota'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'pokemon_id': pokemonId,
    'nome': nome,
    'nota': nota,
  };
}