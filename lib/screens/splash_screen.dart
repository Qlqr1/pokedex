import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../repositories/pokemon_repository.dart';
import '../theme/app_theme.dart';
import 'groups_screen.dart';

/// Tela de abertura animada: a pokébola gira e "encaixa", o título aparece e,
/// enquanto isso, a primeira página de Pokémon é carregada em segundo plano.
/// Depois de um tempo mínimo, entra na tela inicial com um fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _minDuration = Duration(milliseconds: 2400);
  static const _maxWait = Duration(seconds: 5);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _spin;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _subFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _spin = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );
    _titleSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
    );
    _subFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _start();
  }

  Future<void> _start() async {
    // Tempo mínimo da animação + pré-carregamento (sem travar se falhar).
    final preload = PokemonRepository.shared
        .getPokemonPage(limit: 20, offset: 0)
        .then<void>((_) {})
        .catchError((_) {})
        .timeout(_maxWait, onTimeout: () {});
    await Future.wait([Future.delayed(_minDuration), preload]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const GroupsScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brilho vermelho suave atrás da bola
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.red
                                .withAlpha((60 * _scale.value.clamp(0.0, 1.0)).round()),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: (1 - _spin.value) * 2 * math.pi,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: const SizedBox(
                          width: 128,
                          height: 128,
                          child: CustomPaint(painter: _PokeballPainter()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _titleFade.value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - _titleSlide.value)),
                    child: const Text(
                      'Pokédex',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Opacity(
                  opacity: _subFade.value,
                  child: const SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        color: AppColors.red,
                        backgroundColor: AppColors.track,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Pokébola desenhada em código (sem depender de imagem).
class _PokeballPainter extends CustomPainter {
  const _PokeballPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final ring = r * 0.085;
    final inner = Rect.fromCircle(center: c, radius: r - ring);

    final dark = Paint()..color = const Color(0xFF1B1B1F);
    final white = Paint()..color = const Color(0xFFF5F5F7);
    final red = Paint()..color = AppColors.red;

    canvas.drawCircle(c, r, dark);
    canvas.drawArc(inner, math.pi, math.pi, true, red); // metade de cima
    canvas.drawArc(inner, 0, math.pi, true, white); // metade de baixo
    canvas.drawRect(
      Rect.fromCenter(center: c, width: r * 1.99, height: r * 0.17),
      dark,
    );
    canvas.drawCircle(c, r * 0.27, dark);
    canvas.drawCircle(c, r * 0.17, white);
    canvas.drawCircle(c, r * 0.085, Paint()..color = const Color(0xFFDEE0E6));

    // brilho
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-r * 0.48, -r * 0.56),
        width: r * 0.6,
        height: r * 0.42,
      ),
      Paint()..color = const Color.fromRGBO(255, 255, 255, .28),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}