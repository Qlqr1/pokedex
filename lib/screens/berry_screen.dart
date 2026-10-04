import 'package:flutter/material.dart';

import '../models/berry.dart';
import '../repositories/berry_repository.dart';
import '../utils/berry_utils.dart';
import '../widgets/item_sprite.dart';
import '../widgets/type_badge.dart';
import 'item_screen.dart';

/// Página de uma berry: imagem no topo, informações listadas e um botão
/// para a página do item correspondente.
class BerryScreen extends StatefulWidget {
  final String berryName; // ex.: "cheri"
  const BerryScreen({super.key, required this.berryName});

  @override
  State<BerryScreen> createState() => _BerryScreenState();
}

class _BerryScreenState extends State<BerryScreen> {
  late Future<BerryDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = BerryRepository.instance.getBerry(widget.berryName);
  }

  void _retry() => setState(
      () => _future = BerryRepository.instance.getBerry(widget.berryName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(berryLabel(widget.berryName))),
      body: FutureBuilder<BerryDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar esta berry.'),
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

  Widget _content(BerryDetail b) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    final flavors = b.flavors.where((f) => f.potency > 0).toList()
      ..sort((a, c) => c.potency.compareTo(a.potency));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Imagem no topo
        Center(child: ItemSprite(url: ItemSprite.urlFor(b.itemName), size: 120)),
        const SizedBox(height: 8),
        Center(
          child: Text('#${b.id}', style: TextStyle(color: Colors.grey.shade600)),
        ),
        Center(
          child: Text(
            berryLabel(b.name),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),
        _InfoRow('Tempo de crescimento',
            '${b.growthTime} h por estágio (≈ ${b.growthTime * 4} h até a colheita)'),
        _InfoRow('Colheita máxima', '${b.maxHarvest}'),
        _InfoRow('Tamanho', '${b.size} mm'),
        _InfoRow('Firmeza',
            b.firmness == null ? '—' : firmnessLabel(b.firmness!)),
        _InfoRow('Suavidade', '${b.smoothness}'),
        _InfoRow('Ressecamento do solo', '${b.soilDryness}'),
        _InfoRow('Poder do Natural Gift', '${b.naturalGiftPower}'),
        if (b.naturalGiftType != null)
          _InfoRow('Tipo do Natural Gift', '',
              trailing: TypeBadge(type: b.naturalGiftType!)),

        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text('Sabores', style: titleStyle),
        ),
        if (flavors.isEmpty)
          const Text('Sem sabor registrado.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: flavors
                .map((f) => Chip(
                    label: Text('${flavorLabel(f.name)} ${f.potency}')))
                .toList(),
          ),

        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.info_outline),
          label: const Text('Outras informações'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ItemScreen(itemName: b.itemName)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _InfoRow(this.label, this.value, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(label,
                    style: TextStyle(color: Colors.grey.shade700)),
              ),
              Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing ??
                      Text(value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}