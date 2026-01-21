import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/localized_date_labels.dart';
import '../../easter_egg/flappy_pay/flappy_pay_page.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.month,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onRates,
    required this.onTheme,
  });

  final DateTime month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onRates;
  final VoidCallback onTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final title = monthTitleL10n(context, month);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _EasterEggLogo(
                            onTriggered: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const FlappyPayPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: l10n.themesTooltip,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onTheme();
                    },
                    icon: const Icon(Icons.palette),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: l10n.settingsTooltip,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onRates();
                    },
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: l10n.previousMonthTooltip,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onPrevMonth();
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.nextMonthTooltip,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onNextMonth();
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EasterEggLogo extends StatefulWidget {
  const _EasterEggLogo({required this.onTriggered});

  final Future<void> Function() onTriggered;

  @override
  State<_EasterEggLogo> createState() => _EasterEggLogoState();
}

class _EasterEggLogoState extends State<_EasterEggLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  int _tapCount = 0;
  DateTime? _lastTapAt;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_busy) return;
    final now = DateTime.now();
    final last = _lastTapAt;
    _lastTapAt = now;
    if (last == null ||
        now.difference(last) > const Duration(milliseconds: 900)) {
      _tapCount = 0;
    }

    _tapCount += 1;
    HapticFeedback.selectionClick();

    if (_tapCount < 3) return;
    _tapCount = 0;
    _busy = true;

    HapticFeedback.mediumImpact();
    await _controller.forward(from: 0);
    if (!mounted) return;
    await widget.onTriggered();
    if (!mounted) return;
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: l10n.appTitle,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final t = Curves.easeOutBack.transform(_controller.value);
            final scale = 1 + (0.10 * t);
            final wobble = math.sin(_controller.value * math.pi * 6) * 0.03 * t;
            return Transform.rotate(
              angle: wobble,
              child: Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.16 * t),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            themeManager.currentTheme.logo,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
