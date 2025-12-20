import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.blankSpace = 28,
    this.pixelsPerSecond = 28,
    this.pause = const Duration(milliseconds: 400),
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double blankSpace;
  final double pixelsPerSecond;
  final Duration pause;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double? _lastMaxWidth;
  double? _lastTextWidth;
  bool _isRunning = false;
  bool _shouldMarquee = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;
        final textSize = _measureText(widget.text, style);
        final textWidth = textSize.width;
        final textHeight = textSize.height;
        final shouldMarqueeNow = textWidth > maxWidth && maxWidth.isFinite;

        if (!shouldMarqueeNow) {
          _stopMarquee();
          return SizedBox(
            height: textHeight,
            child: Text(
              widget.text,
              style: style,
              textAlign: widget.textAlign,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        _ensureMarqueeStarted(maxWidth: maxWidth, textWidth: textWidth);

        return ClipRect(
          child: SizedBox(
            width: maxWidth,
            height: textHeight,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(widget.text, style: style, maxLines: 1),
                  SizedBox(width: widget.blankSpace),
                  Text(widget.text, style: style, maxLines: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _ensureMarqueeStarted({
    required double maxWidth,
    required double textWidth,
  }) {
    final changed = _lastMaxWidth != maxWidth || _lastTextWidth != textWidth;
    if (!changed && _shouldMarquee && _isRunning) return;

    _lastMaxWidth = maxWidth;
    _lastTextWidth = textWidth;
    _shouldMarquee = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _startLoop();
    });
  }

  void _stopMarquee() {
    _lastMaxWidth = null;
    _lastTextWidth = null;
    _shouldMarquee = false;
  }

  Size _measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    return painter.size;
  }

  Future<void> _startLoop() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      while (mounted && _shouldMarquee && _scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent <= 0) break;

        _scrollController.jumpTo(0);
        await Future<void>.delayed(widget.pause);
        if (!mounted || !_shouldMarquee || !_scrollController.hasClients) break;

        final speed = widget.pixelsPerSecond <= 0 ? 1 : widget.pixelsPerSecond;
        final ms = (maxExtent / speed * 1000).round().clamp(800, 60000);
        await _scrollController.animateTo(
          maxExtent,
          duration: Duration(milliseconds: ms),
          curve: Curves.linear,
        );
        await Future<void>.delayed(widget.pause);
      }
    } finally {
      _isRunning = false;
    }
  }
}
