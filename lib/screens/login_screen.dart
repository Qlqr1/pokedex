import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../theme/app_theme.dart';

/// Entrar ou criar conta. Fecha sozinha quando o login dá certo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  bool _criarConta = false;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _enviar() {
    final usuario = _usuario.text.trim();
    final senha = _senha.text;
    context.read<AuthBloc>().add(
      _criarConta
          ? AuthRegistrarSolicitado(usuario, senha)
          : AuthEntrarSolicitado(usuario, senha),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAutenticado) {
          Navigator.of(context).pop();
        } else if (state is AuthErro) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.mensagem)));
        }
      },
      builder: (context, state) {
        final carregando = state is AuthCarregando;

        return Scaffold(
          appBar: AppBar(title: Text(_criarConta ? 'Criar conta' : 'Entrar')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Entre na sua conta para salvar seus favoritos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usuario,
                      enabled: !carregando,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _senha,
                      enabled: !carregando,
                      obscureText: true,
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        helperText: _criarConta ? 'Mínimo de 6 caracteres' : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: carregando ? null : _enviar,
                      child: carregando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_criarConta ? 'Criar conta' : 'Entrar'),
                    ),
                    TextButton(
                      onPressed: carregando
                          ? null
                          : () => setState(() => _criarConta = !_criarConta),
                      child: Text(
                        _criarConta ? 'Já tenho conta' : 'Criar uma conta',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}