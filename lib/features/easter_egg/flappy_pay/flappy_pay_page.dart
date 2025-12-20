import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/storage/storage.dart';

class FlappyPayPage extends StatefulWidget {
  const FlappyPayPage({super.key});

  @override
  State<FlappyPayPage> createState() => _FlappyPayPageState();
}

class _FlappyPayPageState extends State<FlappyPayPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);

  double _birdY = 0.0;
  double _birdV = 0.0;
  double _time = 0.0;

  bool _started = false;
  bool _dead = false;
  int _score = 0;
  int _best = 0;

  final List<_Pipe> _pipes = <_Pipe>[];

  static const double _gravity = 2.6; // world units / s^2
  static const double _flapImpulse = -1.15; // world units / s
  static const double _pipeSpeed = 0.65;
  static const double _pipeSpacing = 0.95;
  static const double _birdDiameterFactor = 0.13; // * min(screenW, screenH)
  static const double _birdCollisionRadius = 0.045; // world units

  @override
  void initState() {
    super.initState();
    _best = settingsStorage.getBestFlappyScore() ?? 0;
    _reset();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _reset() {
    _birdY = 0.0;
    _birdV = 0.0;
    _time = 0.0;
    _score = 0;
    _started = false;
    _dead = false;
    _pipes
      ..clear()
      ..addAll(_initialPipes());
  }

  List<_Pipe> _initialPipes() {
    final rng = math.Random();
    return List<_Pipe>.generate(3, (int i) {
      final gapCenter = (rng.nextDouble() * 1.0) - 0.5;
      return _Pipe(
        x: 1.2 + (i * _pipeSpacing),
        gapCenterY: gapCenter,
        gapSize: 0.55,
        passed: false,
      );
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (t - _time).clamp(0.0, 0.04);
    _time = t;

    if (!_started || _dead) {
      setState(() {});
      return;
    }

    _birdV += _gravity * dt;
    _birdY += _birdV * dt;

    for (final p in _pipes) {
      p.x -= _pipeSpeed * dt;
    }

    _recyclePipes();
    _checkCollisionsAndScore();
    setState(() {});
  }

  void _recyclePipes() {
    final rng = math.Random();
    final rightMost = _pipes.map((p) => p.x).fold<double>(-999, math.max);
    for (final p in _pipes) {
      if (p.x < -1.35) {
        p
          ..x = rightMost + _pipeSpacing
          ..gapCenterY = (rng.nextDouble() * 1.0) - 0.5
          ..gapSize = 0.55
          ..passed = false;
      }
    }
  }

  void _checkCollisionsAndScore() {
    const birdX = -0.35;
    const birdR = _birdCollisionRadius;
    const groundY = 0.92;
    const skyY = -0.92;

    if (_birdY + birdR > groundY || _birdY - birdR < skyY) {
      _die();
      return;
    }

    for (final p in _pipes) {
      const pipeHalfW = 0.14;
      final pipeLeft = p.x - pipeHalfW;
      final pipeRight = p.x + pipeHalfW;

      final withinX = (birdX + birdR) > pipeLeft && (birdX - birdR) < pipeRight;
      if (withinX) {
        final gapTop = p.gapCenterY - (p.gapSize / 2);
        final gapBottom = p.gapCenterY + (p.gapSize / 2);
        final withinGap =
            (_birdY - birdR) > gapTop && (_birdY + birdR) < gapBottom;
        if (!withinGap) {
          _die();
          return;
        }
      }

      if (!p.passed && p.x < birdX) {
        p.passed = true;
        _score += 1;
        if (_score > _best) _best = _score;
        // Persist the best score in the background.
        settingsStorage.setBestFlappyScore(_best);
        HapticFeedback.selectionClick();
      }
    }
  }

  void _die() {
    if (_dead) return;
    _dead = true;
    HapticFeedback.heavyImpact();
  }

  void _flapOrRestart() {
    if (_dead) {
      HapticFeedback.lightImpact();
      setState(_reset);
      return;
    }

    if (!_started) {
      HapticFeedback.lightImpact();
      setState(() => _started = true);
    } else {
      HapticFeedback.selectionClick();
    }

    _birdV = _flapImpulse;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _flapOrRestart,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFFFF0F7),
                Color(0xFFF2F3FF),
                Color(0xFFEFFFFA),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                Offset worldToPx(double x, double y) {
                  final px = (x + 1) * 0.5 * w;
                  final py = (y + 1) * 0.5 * h;
                  return Offset(px, py);
                }

                final birdPx = worldToPx(-0.35, _birdY);
                final birdSize = math.min(w, h) * _birdDiameterFactor;

                return Stack(
                  children: <Widget>[
                    Positioned(
                      left: 16,
                      top: 12,
                      child: IconButton.filledTonal(
                        tooltip: l10n.close,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 18,
                      child: Column(
                        children: <Widget>[
                          Text(
                            '${l10n.scoreLabel}: $_score',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.bestLabel}: $_best',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    for (final p in _pipes)
                      ..._pipeWidgets(context, p, worldToPx, w, h),
                    Positioned(
                      left: birdPx.dx - (birdSize / 2),
                      top: birdPx.dy - (birdSize / 2),
                      width: birdSize,
                      height: birdSize,
                      child: Transform.rotate(
                        angle: (_birdV * 0.9).clamp(-0.7, 0.7),
                        child: Image.asset(
                          'lib/assets/character.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _GroundBar(color: cs.outlineVariant),
                    ),
                    if (!_started && !_dead)
                      Center(
                        child: _HintCard(
                          text: l10n.tapToFlap,
                          icon: Icons.touch_app,
                        ),
                      ),
                    if (_dead)
                      Center(
                        child: _HintCard(
                          text: l10n.gameOverTapToRetry,
                          icon: Icons.replay,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _pipeWidgets(
    BuildContext context,
    _Pipe p,
    Offset Function(double x, double y) worldToPx,
    double w,
    double h,
  ) {
    final cs = Theme.of(context).colorScheme;
    const pipeHalfW = 0.14;

    final gapTop = p.gapCenterY - (p.gapSize / 2);
    final gapBottom = p.gapCenterY + (p.gapSize / 2);
    final top = worldToPx(p.x, -1).dy;
    final bottom = worldToPx(p.x, 1).dy;

    final left = worldToPx(p.x - pipeHalfW, 0).dx;
    final right = worldToPx(p.x + pipeHalfW, 0).dx;
    final pipeW = (right - left).abs();

    final gapTopPx = worldToPx(0, gapTop).dy;
    final gapBottomPx = worldToPx(0, gapBottom).dy;

    final pipeColor = cs.primaryContainer.withValues(alpha: 0.9);
    final borderColor = cs.primary.withValues(alpha: 0.35);

    return <Widget>[
      Positioned(
        left: left,
        top: top,
        width: pipeW,
        height: (gapTopPx - top).clamp(0, h),
        child: _PipeBody(color: pipeColor, borderColor: borderColor),
      ),
      Positioned(
        left: left,
        top: gapBottomPx,
        width: pipeW,
        height: (bottom - gapBottomPx).clamp(0, h),
        child: _PipeBody(color: pipeColor, borderColor: borderColor),
      ),
    ];
  }
}

class _Pipe {
  _Pipe({
    required this.x,
    required this.gapCenterY,
    required this.gapSize,
    required this.passed,
  });

  double x;
  double gapCenterY;
  double gapSize;
  bool passed;
}

class _PipeBody extends StatelessWidget {
  const _PipeBody({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color,
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: borderColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

class _GroundBar extends StatelessWidget {
  const _GroundBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        border: Border(top: BorderSide(color: color)),
      ),
      child: const SizedBox(height: 18),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        color: Colors.white.withValues(alpha: 0.92),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: cs.primary),
            const SizedBox(width: 10),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
