import 'package:flutter/material.dart';

import '../repositories/item_repository.dart';
import '../widgets/item_sprite.dart';
import '../widgets/named_ref_list_screen.dart';
import 'item_screen.dart';

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Itens',
      searchable: true,
      searchHint: 'Buscar item',
      emptyText: 'Nenhum item encontrado.',
      loader: ItemRepository.instance.getList,
      leading: (r) => ItemSprite(url: ItemSprite.urlFor(r.name)),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemScreen(itemName: r.name)),
      ),
    );
  }
}