import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/carregamento/carregamento_bloc.dart';
import '../bloc/carregamento/carregamento_event.dart';
import '../bloc/carregamento/carregamento_state.dart';

/// Página de detalhe padrão: AppBar + carregamento + erro com "Tentar de novo".
///
/// O carregamento é controlado por um [CarregamentoBloc]; esta classe só
/// cria o BLoC e desenha cada estado.
class AsyncPage<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CarregamentoBloc<T>(loader: loader)
            ..add(const CarregamentoIniciado()),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: BlocBuilder<CarregamentoBloc<T>, CarregamentoState<T>>(
          builder: (context, state) {
            return switch (state) {
              CarregamentoInicial<T>() || CarregamentoCarregando<T>() =>
                const Center(child: CircularProgressIndicator()),
              CarregamentoErro<T>() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorText),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.read<CarregamentoBloc<T>>().add(
                        const CarregamentoNovaTentativa(),
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              CarregamentoSucesso<T>(:final dados) => builder(context, dados),
            };
          },
        ),
      ),
    );
  }
}
