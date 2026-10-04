/// Referência (nome + URL) para outro recurso da PokéAPI.
class NamedApiResource {
  final String name;
  final String url;

  const NamedApiResource({required this.name, required this.url});

  factory NamedApiResource.fromJson(Map<String, dynamic> json) =>
      NamedApiResource(
        name: json['name'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  /// ID numérico extraído do fim da URL (ex.: .../pokemon/25/ -> 25).
  int? get id {
    final segments =
        Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? null : int.tryParse(segments.last);
  }

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}

/// Referência apenas com URL (sem nome), ex.: evolution_chain, machine.
class ApiResource {
  final String url;

  const ApiResource({required this.url});

  factory ApiResource.fromJson(Map<String, dynamic> json) =>
      ApiResource(url: json['url'] as String? ?? '');

  int? get id {
    final segments =
        Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? null : int.tryParse(segments.last);
  }

  Map<String, dynamic> toJson() => {'url': url};
}

/// Resposta paginada das listagens (/pokemon?limit=20&offset=0).
class NamedApiResourceList {
  final int count;
  final String? next;
  final String? previous;
  final List<NamedApiResource> results;

  const NamedApiResourceList({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory NamedApiResourceList.fromJson(Map<String, dynamic> json) =>
      NamedApiResourceList(
        count: json['count'] as int? ?? 0,
        next: json['next'] as String?,
        previous: json['previous'] as String?,
        results: parseList(json['results'], NamedApiResource.fromJson),
      );
}

// ---------- Helpers de parsing usados por todos os models ----------

List<T> parseList<T>(
  dynamic json,
  T Function(Map<String, dynamic>) fromJson,
) =>
    (json as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();

NamedApiResource? parseNamed(dynamic json) => json == null
    ? null
    : NamedApiResource.fromJson(json as Map<String, dynamic>);

ApiResource? parseApi(dynamic json) =>
    json == null ? null : ApiResource.fromJson(json as Map<String, dynamic>);
