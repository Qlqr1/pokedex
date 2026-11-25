import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/favoritos/favoritos_bloc.dart';
import 'bloc/favoritos/favoritos_event.dart';
import 'repositories/auth_repository.dart';
import 'repositories/favoritos_api_repository.dart';
import 'screens/splash_screen.dart';
import 'services/pokedex_api_service.dart';
import 'theme/app_theme.dart';

// Instâncias únicas da API própria: o login e os favoritos precisam
// compartilhar o mesmo AuthRepository (é nele que está o token).
final _api = PokedexApiService();
final _authRepository = AuthRepository(api: _api);
final _favoritosRepository = FavoritosApiRepository(
  api: _api,
  auth: _authRepository,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Barra de status transparente com ícones claros: combina com o cabeçalho
  // vermelho e com o tema escuro.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Os BLoCs ficam acima do MaterialApp para todas as telas os enxergarem.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(repository: _authRepository)..add(const AuthIniciada()),
        ),
        BlocProvider(create: (_) => FavoritosBloc(repository: _favoritosRepository)),
      ],
      // Quando o login muda, os favoritos acompanham: carrega os do usuário que
      // entrou e esvazia ao sair.
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final favoritos = context.read<FavoritosBloc>();
          if (state is AuthAutenticado) {
            favoritos.add(const FavoritosIniciados());
          } else if (state is AuthDeslogado) {
            favoritos.add(const FavoritosLimpos());
          }
        },
        child: MaterialApp(
          title: 'Pokédex',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}