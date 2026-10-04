/// Regras de busca compartilhadas por todas as listas.

/// "Thunder Punch " -> "thunder-punch"
String normalizeQuery(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

/// Casa por parte do nome ou, se for número, pelo id (aceita "0025" e "25").
bool matchesQuery(String name, int? id, String query) {
  if (query.isEmpty) return true;
  if (name.contains(query)) return true;
  final number = int.tryParse(query);
  return number != null && id == number;
}