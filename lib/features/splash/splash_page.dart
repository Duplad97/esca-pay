import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/pay_calendar/pay_calendar_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _float;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55));
    _scaleIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
    );
    _float = CurvedAnimation(parent: _controller, curve: const Interval(0.35, 1.0));

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) => const PayCalendarPage(),
          transitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: fade, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const _SplashBackground(),
              Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Transform.translate(
                    offset: Offset(0, -12 * (1 - _fadeIn.value)),
                    child: Transform.translate(
                      offset: Offset(0, math.sin(_float.value * math.pi * 2) * 6),
                      child: Transform.scale(
                        scale: 0.86 + (0.14 * _scaleIn.value),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: cs.outlineVariant),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.22),
                                    blurRadius: 30,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  themeManager.currentTheme.splashLogo,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _SplashBackground extends StatefulWidget {
  const _SplashBackground();

  @override
  State<_SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<_SplashBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final a = Alignment(-0.8 + (t * 0.9), -1.0 + (math.sin(t * math.pi * 2) * 0.25));
        final b = Alignment(1.0 - (t * 0.9), 1.0 - (math.cos(t * math.pi * 2) * 0.25));
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: a,
              end: b,
              colors: <Color>[
                const Color(0xFFFFF0F7),
                const Color(0xFFF2F3FF),
                const Color(0xFFEFFFFA),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _BlobPainter(
              t: t,
              primary: cs.primary.withValues(alpha: 0.22),
              secondary: cs.secondary.withValues(alpha: 0.18),
              tertiary: cs.tertiary.withValues(alpha: 0.16),
            ),
          ),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({
    required this.t,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final double t;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    void blob({
      required double x,
      required double y,
      required double r,
      required Color color,
    }) {
      paint.color = color;
      canvas.drawCircle(Offset(x * size.width, y * size.height), r * size.shortestSide, paint);
    }

    blob(
      x: 0.18 + (math.sin(t * math.pi * 2) * 0.05),
      y: 0.18 + (math.cos(t * math.pi * 2) * 0.06),
      r: 0.28,
      color: primary,
    );
    blob(
      x: 0.92 - (math.cos(t * math.pi * 2) * 0.06),
      y: 0.22 + (math.sin(t * math.pi * 2) * 0.05),
      r: 0.22,
      color: secondary,
    );
    blob(
      x: 0.70 + (math.sin(t * math.pi * 2) * 0.04),
      y: 0.88 - (math.cos(t * math.pi * 2) * 0.05),
      r: 0.30,
      color: tertiary,
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.tertiary != tertiary;
  }
}
