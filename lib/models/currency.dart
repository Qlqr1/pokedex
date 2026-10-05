class Currency {
  final int id;
  final String name; // ex.: "league-points"
  const Currency({required this.id, required this.name});

  /// A listagem traz {name, url}; o id vem do fim da URL.
  factory Currency.fromJson(Map<String, dynamic> j) {
    final parts =
        (j['url'] as String).split('/').where((e) => e.isNotEmpty).toList();
    final id = int.parse(parts.last);
    return Currency(id: id, name: (j['name'] as String?) ?? 'currency-$id');
  }
}