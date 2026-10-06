import 'package:flutter/material.dart';

import '../models/dex.dart';
import '../screens/egg_group_screen.dart';
import '../screens/habitat_screen.dart';
import '../utils/species_utils.dart';
import 'info_row.dart';

/// Extras da espécie na aba "Sobre": grupos de ovo, gênero, crescimento e
/// habitat.
class SpeciesExtrasView extends StatelessWidget {
  final SpeciesDex dex;
  const SpeciesExtrasView({super.key, required this.dex});

  @override
  Widget build(BuildContext context) {
    final growth = dex.growthRate;
    final exp = growth == null ? null : growthRateExpAt100(growth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Block(
          label: 'Grupos de ovo',
          child: dex.eggGroups.isEmpty
              ? const Text('—')
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final g in dex.eggGroups)
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        label: Text(eggGroupLabel(g)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EggGroupScreen(groupName: g)),
                        ),
                      ),
                  ],
                ),
        ),
        _Block(label: 'Gênero', child: _GenderBar(rate: dex.genderRate)),
        InfoRow(
          'Taxa de crescimento',
          growth == null
              ? '—'
              : exp == null
                  ? growthRateLabel(growth)
                  : '${growthRateLabel(growth)} · ${thousands(exp)} exp (nv. 100)',
        ),
        InfoRow(
          'Habitat',
          dex.habitat == null ? '—' : habitatLabel(dex.habitat!),
          onTap: dex.habitat == null
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HabitatScreen(habitatName: dex.habitat!)),
                  ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final String label;
  final Widget child;
  const _Block({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

/// Distribuição de gênero. `gender_rate` vem em oitavos de chance de fêmea.
class _GenderBar extends StatelessWidget {
  final int rate;
  const _GenderBar({required this.rate});

  static const _male = Color(0xFF42A5F5);
  static const _female = Color(0xFFEC407A);

  @override
  Widget build(BuildContext context) {
    if (rate < 0) return const Text('Sem gênero');

    final female = rate * 12.5;
    final male = 100 - female;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (male > 0) ...[
              const Icon(Icons.male, size: 18, color: _male),
              Text(' ${percent(male)}'),
            ],
            if (male > 0 && female > 0) const SizedBox(width: 16),
            if (female > 0) ...[
              const Icon(Icons.female, size: 18, color: _female),
              Text(' ${percent(female)}'),
            ],
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (male > 0)
                  Expanded(
                      flex: (male * 10).round(),
                      child: Container(color: _male)),
                if (female > 0)
                  Expanded(
                      flex: (female * 10).round(),
                      child: Container(color: _female)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}