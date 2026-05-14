import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'cinematic_captions_widget.dart';

class KenBurnsMediaItem extends StatefulWidget {
  final String imageUrl;
  final String arabic;
  final String quote;
  final String author;
  final bool isActive;
  final bool isPaused;
  final bool isViewed;
  final bool isLoved;
  final bool isSaved;
  final String? aiInsight;
  final String? moodTag;
  final String? likes;
  final String? views;
  final String? shares;
  final VoidCallback? onLikeTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMainTap;

  const KenBurnsMediaItem({
    super.key,
    required this.imageUrl,
    required this.arabic,
    required this.quote,
    required this.author,
    required this.isActive,
    this.isPaused = false,
    this.isViewed = false,
    this.isLoved = false,
    this.isSaved = false,
    this.aiInsight,
    this.moodTag,
    this.likes,
    this.views,
    this.shares,
    this.onLikeTap,
    this.onSaveTap,
    this.onShareTap,
    this.onMainTap,
  });

  @override
  State<KenBurnsMediaItem> createState() => _KenBurnsMediaItemState();
}

class _KenBurnsMediaItemState extends State<KenBurnsMediaItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // HUD Pop Animation Elements
  late AnimationController _hudController;
  late Animation<double> _hudScale;
  late Animation<double> _hudOpacity;

  // Giant Heart Burst Animation Elements
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late Animation<double> _heartOpacity;

  @override
  void initState() {
    super.initState();
    
    // Background dynamic Ken Burns zoom controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isActive && !widget.isPaused) {
      _controller.repeat(reverse: true);
    }

    // HUD bounce controller initialization for toggle events
    _hudController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _hudScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(_hudController);

    _hudOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(_hudController);

    // Double-tap heart burst controller initialization
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.4).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.6), weight: 40),
    ]).animate(_heartController);

    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_heartController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _hudController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KenBurnsMediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Sync Background Animation Controller instantly to the central play state
    if (widget.isActive && !widget.isPaused) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }

    // Trigger centered HUD temporary pop animation on toggles
    if (widget.isActive && widget.isPaused != oldWidget.isPaused) {
      _hudController.forward(from: 0.0);
    }
  }

  void _handleDoubleTapLove() {
    // Double tapping triggers local Love animation burst
    _heartController.forward(from: 0.0);
    
    // If it hasn't been loved yet, trigger optimistic backend hook!
    if (!widget.isLoved && widget.onLikeTap != null) {
      widget.onLikeTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. THE ANIMATED BACKGROUND IMAGE
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black87,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white30),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            );
          },
        ),

        // 2. TOUCH GESTURE ENGINE CANVAS (Single tap for play/pause, double tap for Love)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onMainTap,
            onDoubleTap: _handleDoubleTapLove,
            child: Container(color: Colors.transparent),
          ),
        ),

        // 3. GRADIENT VIGNETTE FOR TEXT CONTRAST
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(140),
                    Colors.black.withAlpha(40),
                    Colors.black.withAlpha(40),
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0.0, 0.25, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 4. CENTERED HUD TEMPORARY POP OVERLAY
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _hudController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _hudOpacity.value,
                    child: Transform.scale(
                      scale: _hudScale.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(90),
                        ),
                        child: Icon(
                          widget.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 5. DEDICATED GIANT HEART BURST OVERLAY (FOR DOUBLE TAP)
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _heartController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _heartOpacity.value,
                    child: Transform.scale(
                      scale: _heartScale.value,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 120,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 20)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 6. ELEGANT PERSISTENT GLASSMORPHISM PLAY OVERLAY WHEN PAUSED
        if (widget.isPaused)
          Center(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 250),
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val * 0.85,
                    child: Transform.scale(
                      scale: 0.8 + (val * 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(100),
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // 7. TOP-LEFT GLASSMORPHIC "VIEWED" CHIP
        if (widget.isViewed)
          Positioned(
            top: 92,
            left: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutQuad,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1.0 - value) * 10),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.remove_red_eye, color: Colors.white70, size: 13),
                    SizedBox(width: 6),
                    Text(
                      "Viewed",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 8. DEDICATED CENTERED SUBTITLE SHIELD
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.black.withAlpha(120),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: CinematicCaptionsWidget(
                  key: ValueKey(widget.arabic),
                  arabic: widget.arabic,
                  translation: widget.quote,
                  isActive: widget.isActive,
                  isPaused: widget.isPaused,
                ),
              ),
            ),
          ),
        ),

        // 9. CONTENT OVERLAYS
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Side: Minimalist Source/Author overlay at bottom left
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: SingleChildScrollView(
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.moodTag != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withAlpha(60), width: 1),
                              ),
                              child: Text(
                                "#${widget.moodTag!.toUpperCase()}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (widget.aiInsight != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                widget.aiInsight!,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(230),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            widget.author,
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 14,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w800,
                              shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right Side: Floating Action Icons matching dynamic real-time metrics
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 1. Favorite / Love Button
                      _buildFloatingAction(
                        widget.isLoved ? Icons.favorite : Icons.favorite_border, 
                        widget.likes ?? "Like",
                        iconColor: widget.isLoved ? Colors.redAccent : Colors.white,
                        onTap: widget.onLikeTap,
                      ),
                      const SizedBox(height: 20),
                      
                      // 2. Bookmark / Save Button
                      _buildFloatingAction(
                        widget.isSaved ? Icons.bookmark : Icons.bookmark_border, 
                        "Save",
                        iconColor: widget.isSaved ? Colors.amberAccent : Colors.white,
                        onTap: widget.onSaveTap,
                      ),
                      const SizedBox(height: 20),

                      // 3. Authentic View Counter
                      _buildFloatingAction(
                        Icons.remove_red_eye_outlined, 
                        widget.views ?? "0",
                        onTap: null,
                      ),
                      const SizedBox(height: 20),

                      // 4. Native Share Button
                      _buildFloatingAction(
                        Icons.share_rounded, 
                        widget.shares ?? "Share",
                        onTap: widget.onShareTap,
                      ),
                      const SizedBox(height: 40), // Clearance
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingAction(IconData icon, String label, {Color iconColor = Colors.white, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor != Colors.white ? iconColor.withAlpha(25) : Colors.black.withAlpha(80),
              border: Border.all(color: iconColor != Colors.white ? iconColor.withAlpha(75) : Colors.white.withAlpha(30)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                child: child,
              ),
              child: Icon(icon, key: ValueKey("${icon.hashCode}_$iconColor"), color: iconColor, size: 26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
