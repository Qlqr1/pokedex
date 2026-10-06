import 'package:flutter/material.dart';

/// Página de detalhe padrão: AppBar + carregamento + erro com "Tentar de novo".
class AsyncPage<T> extends StatefulWidget {
  final String title;
  final Future<T> Function() loader;
  final Widget Function(BuildContext context, T data) builder;
  final String errorText;

  const AsyncPage({
    super.key,
    required this.title,
    required this.loader,
    required this.builder,
    this.errorText = 'Não foi possível carregar esta página.',
  });

  @override
  State<AsyncPage<T>> createState() => _AsyncPageState<T>();
}

class _AsyncPageState<T> extends State<AsyncPage<T>> {
  late Future<T> _future;

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
      body: FutureBuilder<T>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.errorText),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          return widget.builder(context, snap.data as T);
        },
      ),
    );
  }
}