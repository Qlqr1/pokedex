import 'package:flutter/material.dart';

import '../models/language.dart';
import '../repositories/language_repository.dart';
import '../services/language_controller.dart';
import '../theme/app_theme.dart';
import '../utils/lang.dart';

/// Folha de seleção de idioma, montada com o endpoint /language.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  late Future<List<LanguageInfo>> _future;

  @override
  void initState() {
    super.initState();
    _future = LanguageRepository.instance.getLanguages();
  }

  void _retry() =>
      setState(() => _future = LanguageRepository.instance.getLanguages());

  Future<void> _select(LanguageInfo l) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await LanguageController.instance.setLanguage(l.name);
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Idioma do conteúdo: ${l.flag} ${l.nativeName}')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text('Idioma do conteúdo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Traduz os textos que vêm da PokéAPI (descrições, efeitos, '
                'nomes). O que não existir no idioma escolhido aparece em inglês.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
            Flexible(
              child: FutureBuilder<List<LanguageInfo>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Text('Não foi possível carregar os idiomas.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: _retry,
                              child: const Text('Tentar novamente')),
                        ]),
                      ),
                    );
                  }
                  final list = snap.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final l = list[i];
                      final selected = l.name == Lang.code;
                      return ListTile(
                        leading:
                            Text(l.flag, style: const TextStyle(fontSize: 26)),
                        title: Text(l.nativeName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          l.nativeName == l.englishName
                              ? l.name
                              : '${l.englishName} · ${l.name}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 11),
                        ),
                        trailing: selected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.red)
                            : null,
                        onTap: () => _select(l),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
