import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/ken_burns_media_item.dart';

class VideoFeedPage extends NyStatefulWidget {
  static RouteView path = ("/video-feed", (_) => VideoFeedPage());

  VideoFeedPage({super.key}) : super(child: () => _VideoFeedPageState());
}

class _VideoFeedPageState extends NyPage<VideoFeedPage> {
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Map<String, String>> _feedItems = [
    {
      "imageUrl": "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80",
      "arabic": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
      "quote": "“Indeed, with hardship [will be] ease.”",
      "author": "Surah Ash-Sharh [94:6]",
      "audioUrl": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    },
    {
      "imageUrl": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80",
      "arabic": "وَوَجَدَكَ ضَالًّا فَهَدَىٰ",
      "quote": "“And he found you lost and guided [you].”",
      "author": "Surah Ad-Duha [93:7]",
      "audioUrl": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    },
    {
      "imageUrl": "https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80",
      "arabic": "فَاذْكُرُونِي أَذْكُرْكُمْ",
      "quote": "“So remember Me; I will remember you.”",
      "author": "Surah Al-Baqarah [2:152]",
      "audioUrl": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    },
    {
      "imageUrl": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80",
      "arabic": "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      "quote": "“Unquestionably, by the remembrance of Allah hearts are assured.”",
      "author": "Surah Ar-Ra'd [13:28]",
      "audioUrl": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    },
  ];

  @override
  get init => () {
        _audioPlayer = AudioPlayer();
        _pageController = PageController();
        // Start playing the first one
        _playCurrentTrack();
      };

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playCurrentTrack() async {
    try {
      await _audioPlayer.stop();
      final url = _feedItems[_currentIndex]["audioUrl"]!;
      await _audioPlayer.play(UrlSource(url));
      // Set to loop for immersive vibe
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Set reasonable immersive volume
      await _audioPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint("Error playing audio track: $e");
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. VERTICAL PAGE VIEW
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _feedItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _playCurrentTrack();
            },
            itemBuilder: (context, index) {
              final item = _feedItems[index];
              return KenBurnsMediaItem(
                key: ValueKey(item["imageUrl"]),
                imageUrl: item["imageUrl"]!,
                arabic: item["arabic"]!,
                quote: item["quote"]!,
                author: item["author"]!,
                isActive: _currentIndex == index,
              );
            },
          ),

          // 2. TOP OVERLAY CONTROLS (BACK BUTTON, TITLE)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withAlpha(80),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      "Ava Moments",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Center compensation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
