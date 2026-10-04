/// Referência {name, url} usada em toda a PokeAPI.
class NamedRef {
  final String name;
  final String url;
  const NamedRef({required this.name, required this.url});

  factory NamedRef.fromJson(Map<String, dynamic> j) =>
      NamedRef(name: j['name'] as String, url: j['url'] as String);

  /// ID extraído da URL (ex.: .../ability/65/ -> 65)
  int get id {
    final parts = url.split('/').where((e) => e.isNotEmpty).toList();
    return int.parse(parts.last);
  }
}