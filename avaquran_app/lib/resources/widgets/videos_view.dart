import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/resources/widgets/trend_video_card_widget.dart';
import 'package:avaquran_app/resources/pages/video_feed_page.dart';

class VideosView extends StatelessWidget {
  const VideosView({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated video data
    final List<Map<String, dynamic>> videos = [
      {
        "title": "Beauty of Patience",
        "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        "duration": "45s",
        "likes": "1.2K",
      },
      {
        "title": "Evening Reflections",
        "image": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b",
        "duration": "30s",
        "likes": "850",
      },
      {
        "title": "Morning Dhikr",
        "image": "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05",
        "duration": "60s",
        "likes": "2.4K",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Short Reflections",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Watch vertical video reflections from the community.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return TrendVideoCard(
                title: video['title'],
                image: video['image'],
                duration: video['duration'],
                likes: video['likes'],
                onTap: () => routeTo(VideoFeedPage.path),
              );
            },
          ),
        ),
      ],
    );
  }
}
