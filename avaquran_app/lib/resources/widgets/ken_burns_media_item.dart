import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'cinematic_captions_widget.dart';

class KenBurnsMediaItem extends StatefulWidget {
  final String imageUrl;
  final String arabic;
  final String quote;
  final String author;
  final bool isActive;

  const KenBurnsMediaItem({
    super.key,
    required this.imageUrl,
    required this.arabic,
    required this.quote,
    required this.author,
    required this.isActive,
  });

  @override
  State<KenBurnsMediaItem> createState() => _KenBurnsMediaItemState();
}

class _KenBurnsMediaItemState extends State<KenBurnsMediaItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KenBurnsMediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
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

        // 2. GRADIENT VIGNETTE FOR TEXT CONTRAST
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.black.withAlpha(40), // Brighter center for the animated background visual
                  Colors.black.withAlpha(40),
                  Colors.black.withAlpha(200),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // 3. DEDICATED CENTERED SUBTITLE SHIELD
        Positioned.fill(
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
                key: ValueKey(widget.arabic), // Force state reinit on change
                arabic: widget.arabic,
                translation: widget.quote,
                isActive: widget.isActive,
              ),
            ),
          ),
        ),

        // 3. CONTENT OVERLAYS
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.author,
                          style: TextStyle(
                            color: Colors.white.withAlpha(160),
                            fontSize: 14,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                            shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Side: Floating Action Icons
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildFloatingAction(Icons.favorite, "1.2k"),
                      const SizedBox(height: 20),
                      _buildFloatingAction(Icons.bookmark, "Save"),
                      const SizedBox(height: 20),
                      _buildFloatingAction(Icons.share, "Share"),
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

  Widget _buildFloatingAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withAlpha(80),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
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
    );
  }
}
