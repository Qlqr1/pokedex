import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../repositories/currency_repository.dart';
import '../utils/string_utils.dart';

/// Grupo Currencies: lista simples (a API só tem id e nome).
class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  State<CurrencyListScreen> createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  late Future<List<Currency>> _future;

  @override
  void initState() {
    super.initState();
    _future = CurrencyRepository.instance.getList();
  }

  void _retry() =>
      setState(() => _future = CurrencyRepository.instance.getList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currencies')),
      body: FutureBuilder<List<Currency>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar as moedas.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Nenhuma moeda encontrada.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = items[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${c.id}')),
                title: Text(c.name.pretty),
              );
            },
          );
        },
      ),
    );
  }
}