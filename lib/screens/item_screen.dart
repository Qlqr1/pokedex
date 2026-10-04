import 'package:flutter/material.dart';

import '../models/item.dart';
import '../repositories/item_repository.dart';
import '../utils/string_utils.dart';
import '../widgets/item_sprite.dart';
import '../widgets/pokemon_learners_section.dart';

/// Página de um item: imagem no topo, depois as informações em lista.
class ItemScreen extends StatefulWidget {
  final String itemName;
  const ItemScreen({super.key, required this.itemName});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  static const _attributeLabels = {
    'countable': 'Contável',
    'consumable': 'Consumível',
    'usable-overworld': 'Usável fora de batalha',
    'usable-in-battle': 'Usável em batalha',
    'holdable': 'Segurável',
    'holdable-passive': 'Segurável (passivo)',
    'holdable-active': 'Segurável (ativo)',
    'underground': 'Subterrâneo',
  };

  late Future<Item> _future;

  @override
  void initState() {
    super.initState();
    _future = ItemRepository.instance.getItem(widget.itemName);
  }

  void _retry() => setState(
      () => _future = ItemRepository.instance.getItem(widget.itemName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.itemName.pretty)),
      body: FutureBuilder<Item>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar este item.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          return _content(snap.data!);
        },
      ),
    );
  }

  Widget _content(Item item) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    Widget section(String title, String text) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(title, style: titleStyle),
            ),
            Text(text),
          ],
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Imagem no topo
        Center(
          child: ItemSprite(
            url: item.spriteUrl ?? ItemSprite.urlFor(item.name),
            size: 120,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('#${item.id}',
              style: TextStyle(color: Colors.grey.shade600)),
        ),
        Center(
          child: Text(
            item.displayName ?? item.name.pretty,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        if (item.category.isNotEmpty)
          Center(child: Chip(label: Text(item.category.pretty))),

        // Números
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Info(
                label: 'Custo',
                value: item.cost > 0 ? '₽ ${item.cost}' : '—'),
            _Info(
                label: 'Poder de arremesso',
                value: item.flingPower?.toString() ?? '—'),
            if (item.flingEffect != null)
              _Info(
                  label: 'Efeito do arremesso',
                  value: item.flingEffect!.pretty),
          ],
        ),

        if (item.attributes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text('Atributos', style: titleStyle),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: item.attributes
                .map((a) => Chip(label: Text(_attributeLabels[a] ?? a.pretty)))
                .toList(),
          ),
        ],

        // A PokéAPI não tem textos em português; usamos o inglês.
        if (item.shortEffect != null) section('Resumo', item.shortEffect!),
        if (item.effect != null && item.effect != item.shortEffect)
          section('Efeito', item.effect!),
        if (item.flavorText != null)
          section('Descrição no jogo', item.flavorText!),

        if (item.heldBy.isNotEmpty)
          PokemonLearnersSection(
            title: 'Segurado por Pokémon selvagens',
            emptyText: '',
            learners: item.heldBy.map((p) => LearnerEntry(p.name)).toList(),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}