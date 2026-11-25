import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/bloc/carregamento/carregamento_bloc.dart';
import 'package:pokedex/bloc/carregamento/carregamento_event.dart';
import 'package:pokedex/bloc/carregamento/carregamento_state.dart';

void main() {
  group('CarregamentoBloc', () {
    test('começa no estado Inicial', () async {
      final bloc = CarregamentoBloc<int>(loader: () async => 1);
      expect(bloc.state, isA<CarregamentoInicial<int>>());
      await bloc.close();
    });

    test('emite Carregando e depois Sucesso com os dados', () async {
      final bloc = CarregamentoBloc<int>(loader: () async => 42);

      final esperado = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CarregamentoCarregando<int>>(),
          isA<CarregamentoSucesso<int>>().having((s) => s.dados, 'dados', 42),
        ]),
      );

      bloc.add(const CarregamentoIniciado());
      await esperado;
      await bloc.close();
    });

    test('Tentar novamente refaz a carga depois de um erro', () async {
      var chamadas = 0;
      final bloc = CarregamentoBloc<int>(
        loader: () async {
          chamadas++;
          if (chamadas == 1) throw Exception('falha');
          return 7;
        },
      );

      final esperado = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CarregamentoCarregando<int>>(),
          isA<CarregamentoErro<int>>(),
          isA<CarregamentoCarregando<int>>(),
          isA<CarregamentoSucesso<int>>().having((s) => s.dados, 'dados', 7),
        ]),
      );

      bloc.add(const CarregamentoIniciado());
      await bloc.stream.firstWhere((s) => s is CarregamentoErro<int>);
      bloc.add(const CarregamentoNovaTentativa());

      await esperado;
      await bloc.close();
      expect(chamadas, 2);
    });
  });
}