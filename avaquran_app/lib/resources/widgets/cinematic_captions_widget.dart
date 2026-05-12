import 'dart:async';
import 'package:flutter/material.dart';

class CinematicCaptionsWidget extends StatefulWidget {
  final String arabic;
  final String translation;
  final bool isActive;

  const CinematicCaptionsWidget({
    super.key,
    required this.arabic,
    required this.translation,
    required this.isActive,
  });

  @override
  State<CinematicCaptionsWidget> createState() => _CinematicCaptionsWidgetState();
}

class _CinematicCaptionsWidgetState extends State<CinematicCaptionsWidget> {
  
  int _revealedWordCount = 0;
  List<String> _arabicWords = [];
  List<String> _translationWords = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _arabicWords = widget.arabic.split(' ');
    _translationWords = widget.translation.split(' ');

    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startSequence();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CinematicCaptionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startSequence();
    } else if (!widget.isActive && oldWidget.isActive) {
      _resetSequence();
    }
  }

  void _startSequence() {
    _resetSequence();

    // Staggered revealing of words to simulate narration timing
    int totalStepCount = (_arabicWords.length > _translationWords.length)
        ? _arabicWords.length
        : _translationWords.length;

    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      setState(() {
        _revealedWordCount++;
      });
      if (_revealedWordCount >= totalStepCount + 2) {
        _timer?.cancel();
      }
    });
  }

  void _resetSequence() {
    _timer?.cancel();
    setState(() {
      _revealedWordCount = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. ARABIC AYAT TEXT
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 5,
              children: List.generate(_arabicWords.length, (index) {
                bool isRevealed = index < _revealedWordCount;
                bool isCurrentlySpoken = index == _revealedWordCount - 1;

                return AnimatedScale(
                  scale: isRevealed ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: isRevealed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: Text(
                      _arabicWords[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrentlySpoken
                            ? const Color(0xFF267B92)
                            : Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Traditional Arabic', // Mocked fallback
                        shadows: [
                          Shadow(
                            color: Colors.black
                                .withAlpha(isCurrentlySpoken ? 200 : 150),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                          if (isCurrentlySpoken)
                            const Shadow(
                              color: Color(0xFF267B92),
                              blurRadius: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // 2. TRANSLATION TEXT
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 2,
            children: List.generate(_translationWords.length, (index) {
              // Staggered translation reveals slightly after Arabic words start
              bool isRevealed = index < (_revealedWordCount - 1);
              return AnimatedOpacity(
                opacity: isRevealed ? 0.85 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _translationWords[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(0, 2)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
