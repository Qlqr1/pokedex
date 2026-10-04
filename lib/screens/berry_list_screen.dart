import 'package:flutter/material.dart';

import '../repositories/berry_repository.dart';
import '../utils/berry_utils.dart';
import '../widgets/item_sprite.dart';
import '../widgets/named_ref_list_screen.dart';
import 'berry_screen.dart';

class BerryListScreen extends StatelessWidget {
  const BerryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Berries',
      searchable: true,
      searchHint: 'Buscar berry',
      emptyText: 'Nenhuma berry encontrada.',
      loader: BerryRepository.instance.getList,
      label: (r) => berryLabel(r.name),
      leading: (r) => ItemSprite(url: ItemSprite.urlFor(berryItemName(r.name))),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BerryScreen(berryName: r.name)),
      ),
    );
  }
}