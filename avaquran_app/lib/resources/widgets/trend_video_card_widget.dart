import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/video_feed_page.dart';

class TrendVideoCard extends StatefulWidget {
  final String title;
  final String image;
  final String duration;

  const TrendVideoCard({
    super.key,
    required this.title,
    required this.image,
    required this.duration,
  });

  @override
  createState() => _TrendVideoCardState();
}

class _TrendVideoCardState extends NyState<TrendVideoCard> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return GestureDetector(
      onTap: () => routeTo(VideoFeedPage.path),
      child: Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // THUMBNAIL
            Image.asset(
              widget.image,
              fit: BoxFit.cover,
            ),

            // GRADIENT OVERLAY (Light top, dark bottom)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      Colors.black.withAlpha(60),
                      Colors.transparent,
                      Colors.black.withAlpha(220),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP DURATION CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          widget.duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM TITLE
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // CENTER PLAY ICON
            Center(
              child: Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
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
          ],
        ),
      ),
      ),
    );
  }
}
