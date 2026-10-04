import 'package:flutter/material.dart';

import '../models/models.dart';

/// Galeria com todas as imagens de um Pokémon, agrupadas por origem.
/// "Por jogo" (dezenas de sprites antigas) fica recolhido e só carrega
/// as imagens quando é aberto. Tocar em uma imagem abre em tela ampliada.
class SpriteGallery extends StatelessWidget {
  final PokemonSprites sprites;

  const SpriteGallery({super.key, required this.sprites});

  @override
  Widget build(BuildContext context) {
    final byGroup = <String, List<SpriteImage>>{};
    for (final image in sprites.gallery) {
      byGroup.putIfAbsent(image.group, () => []).add(image);
    }

    if (byGroup.isEmpty) {
      return const Text('Nenhuma imagem disponível para esta forma.');
    }

    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    final children = <Widget>[];
    byGroup.forEach((group, images) {
      final smooth = group == PokemonSprites.groupArtwork ||
          group == PokemonSprites.groupHome;

      if (group == PokemonSprites.groupByGame) {
        children.add(
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              // Chave própria: sem ela, o tile lê do PageStorage a posição de
              // rolagem da aba (um número) como se fosse "aberto/fechado".
              key: const PageStorageKey<String>('galeria-por-jogo'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text('$group (${images.length})', style: titleStyle),
              children: [_Grid(images: images, smooth: false)],
            ),
          ),
        );
      } else {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(group, style: titleStyle),
        ));
        children.add(_Grid(images: images, smooth: smooth));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _Grid extends StatelessWidget {
  static const double _spacing = 8;
  static const int _columns = 3;

  final List<SpriteImage> images;

  /// true = suaviza a imagem (artes grandes); false = mantém os pixels nítidos.
  final bool smooth;

  const _Grid({required this.images, required this.smooth});

  // Wrap em vez de GridView: o GridView é um Scrollable e lê/grava no
  // PageStorage, o que colidia com o estado do ExpansionTile e da aba.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            ((constraints.maxWidth - _spacing * (_columns - 1)) / _columns)
                .floorToDouble();
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: images
              .map((image) => SizedBox(
                    width: width,
                    height: width / 0.8,
                    child: _SpriteTile(image: image, smooth: smooth),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SpriteTile extends StatelessWidget {
  final SpriteImage image;
  final bool smooth;

  const _SpriteTile({required this.image, required this.smooth});

  FilterQuality get _quality => smooth ? FilterQuality.medium : FilterQuality.none;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openViewer(context),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                image.url,
                fit: BoxFit.contain,
                filterQuality: _quality,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            image.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: InteractiveViewer(
                  child: Image.network(
                    image.url,
                    fit: BoxFit.contain,
                    filterQuality: _quality,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 64),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(image.label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}