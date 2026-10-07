import 'package:flutter/material.dart';

import '../models/named_ref.dart';
import '../utils/search_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_search_field.dart';
import 'poke_tile.dart';

/// Tela de lista genérica (regiões, localizações, áreas, itens...):
/// carrega, mostra erro com "Tentar novamente", busca opcional e rodapé.
/// Usa ListView.builder, então aguenta listas grandes (ex.: ~2000 itens).
class NamedRefListScreen extends StatefulWidget {
  final String title;
  final Future<List<NamedRef>> Function() loader;
  final String Function(NamedRef) label;
  final void Function(BuildContext, NamedRef) onTap;
  final Widget Function(NamedRef)? leading;
  final bool searchable;
  final String searchHint;

  /// Se true, digitar um número também acha o item pelo id.
  final bool searchById;
  final String emptyText;

  /// Itens extras depois da lista (ex.: "Pal Park" no fim das regiões).
  final List<Widget> footer;

  NamedRefListScreen({
    super.key,
    required this.title,
    required this.loader,
    required this.onTap,
    String Function(NamedRef)? label,
    this.leading,
    this.searchable = false,
    this.searchHint = 'Buscar',
    this.searchById = true,
    this.emptyText = 'Nada encontrado.',
    this.footer = const [],
  }) : label = label ?? ((r) => r.name.pretty);

  @override
  State<NamedRefListScreen> createState() => _NamedRefListScreenState();
}

class _NamedRefListScreenState extends State<NamedRefListScreen> {
  late Future<List<NamedRef>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _retry() => setState(() => _future = widget.loader());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<NamedRef>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar a lista.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          final items = snap.data!
              .where(
                (r) => matchesQuery(
                  r.name,
                  widget.searchById ? r.id : null,
                  _query,
                ),
              )
              .toList();
          final emptyRows = items.isEmpty ? 1 : 0;
          final total = emptyRows + items.length + widget.footer.length;

          return Column(
            children: [
              if (widget.searchable)
                ListSearchField(
                  hint: widget.searchHint,
                  onChanged: (v) => setState(() => _query = normalizeQuery(v)),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: total,
                  itemBuilder: (context, i) {
                    if (emptyRows == 1 && i == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(widget.emptyText)),
                      );
                    }
                    final idx = i - emptyRows;
                    if (idx >= items.length) {
                      return widget.footer[idx - items.length];
                    }
                    final r = items[idx];
                    return PokeTile(
                      leading: widget.leading?.call(r),
                      title: widget.label(r),
                      onTap: () => widget.onTap(context, r),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
