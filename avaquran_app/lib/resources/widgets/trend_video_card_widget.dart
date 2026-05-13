import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrendVideoCard extends StatefulWidget {
  final String title;
  final String image;
  final String duration;
  final String likes;
  final bool isLoved;
  final VoidCallback? onTap;

  const TrendVideoCard({
    super.key,
    required this.title,
    required this.image,
    required this.duration,
    required this.likes,
    this.isLoved = false,
    this.onTap,
  });

  @override
  State<TrendVideoCard> createState() => _TrendVideoCardState();
}

class _TrendVideoCardState extends State<TrendVideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. CINEMATIC NETWORK THUMBNAIL WITH CACHING
                CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.black87,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.image_not_supported, color: Colors.white24),
                  ),
                ),

                // 2. RICH GRADIENT OVERLAY
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          Colors.black.withAlpha(70),
                          Colors.transparent,
                          Colors.black.withAlpha(240),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. CENTER PLAY ACTION HUD
                Center(
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // 4. FOREGROUND DYNAMIC METADATA (BOTTOM-HEAVY LAYOUT)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Title Header
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                      
                      const SizedBox(height: 8),

                      // Dynamic Engagement Footer Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Duration
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.white70, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                widget.duration,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Right: Real-time Dynamic Likes
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isLoved ? Icons.favorite : Icons.favorite_border,
                                color: widget.isLoved ? Colors.redAccent : Colors.white70,
                                size: 11,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.likes,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
