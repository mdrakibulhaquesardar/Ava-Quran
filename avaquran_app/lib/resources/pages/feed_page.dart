import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/trend_video_card_widget.dart';
import '/resources/widgets/blog_card_widget.dart';

class FeedPage extends NyStatefulWidget {
  static RouteView path = ("/feed", (_) => FeedPage());

  FeedPage({super.key}) : super(child: () => _FeedPageState());
}

class _FeedPageState extends NyPage<FeedPage> {
  final List<String> _navTabs = [
    "Feed",
    "Peoples",
    "Videos",
    "Blogs",
    "Playlists",
  ];
  int _selectedNavTabIndex = 0;
  int _selectedSubTabIndex = 0; // 0 for Discover, 1 for Following

  // BRAND COLOR
  final Color _brandAccent = const Color(0xFF267B92);

  final List<Map<String, dynamic>> _moods = [
    {
      "name": "Stressed",
      "icon": Icons.sentiment_very_dissatisfied,
      "color": const Color(0xFFE6A490),
    },
    {
      "name": "Anxious",
      "icon": Icons.psychology,
      "color": const Color(0xFF9DBAEB),
    },
    {
      "name": "Grateful",
      "icon": Icons.volunteer_activism,
      "color": const Color(0xFFD1B979),
    },
    {
      "name": "Hopeful",
      "icon": Icons.wb_sunny_outlined,
      "color": const Color(0xFFA4C49D),
    },
    {
      "name": "Distracted",
      "icon": Icons.blur_circular,
      "color": const Color(0xFFB5A6C8),
    },
    {
      "name": "Peaceful",
      "icon": Icons.spa,
      "color": const Color(0xFF7FBAB3),
    },
  ];

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9FAFB,
      ), // Slightly off-white premium back
      body: Stack(
        children: [
          // 1. SUBTLE ISLAMIC BACKGROUND PATTERN TILE
          Positioned.fill(
            child: Image.asset(
              "assets/images/pattern_light_soft.png",
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.60), // Optimized soft opacity
            ),
          ),

          // 2. MAIN CONTENT IN FRONT
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP HEADER ROW
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ava Qurania", // Updated branding
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          _buildCircleIconButton(Icons.add),
                          const SizedBox(width: 12),
                          _buildCircleIconButton(
                            Icons.notifications_none_outlined,
                          ),
                          const SizedBox(width: 12),
                          _buildCircleIconButton(Icons.search),
                        ],
                      ),
                    ],
                  ),
                ),

                // HORIZONTAL SCROLLING TOP TABS
                Container(
                  height: 42,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _navTabs.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = index == _selectedNavTabIndex;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedNavTabIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _brandAccent
                                : Colors.white.withAlpha(150),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _brandAccent.withAlpha(50),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                            border: !isSelected
                                ? Border.all(color: Colors.black.withAlpha(15))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _navTabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // SCROLLABLE MAIN CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SUB-TAB DISCOVER / FOLLOWING TOGGLE
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 6,
                          ),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(200),
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedSubTabIndex = 0,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: _selectedSubTabIndex == 0
                                            ? _brandAccent.withAlpha(30)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Discover",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedSubTabIndex == 0
                                                ? _brandAccent
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedSubTabIndex = 1,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: _selectedSubTabIndex == 1
                                            ? _brandAccent.withAlpha(30)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Following",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _selectedSubTabIndex == 1
                                                ? _brandAccent
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // TRENDING VIDEOS SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: const [
                              Text("🔥", style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                "Trending Videos",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // HORIZONTAL VIDEO LIST
                        SizedBox(
                          height: 190,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: const [
                              TrendVideoCard(
                                title: "The Beauty and of the Holy Quran...",
                                duration: "5 min",
                                image: "assets/images/video_1.png",
                              ),
                              TrendVideoCard(
                                title: "The Divine Peace within Nature...",
                                duration: "7 min",
                                image: "assets/images/video_2.png",
                              ),
                              TrendVideoCard(
                                title: "Finding Peace through daily Prayers...",
                                duration: "4 min",
                                image: "assets/images/onboarding_1.png",
                              ),
                            ],
                          ),
                        ),

                        // PAGINATION DOTS OVERLAY SIMULATED
                        const SizedBox(height: 12),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      _brandAccent, // Swapped from generic black
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // MOOD SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.mood,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "How do you feel?",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Ava personalized Quran moments to your mood.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withAlpha(130),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // TOPICS CHIP WRAPPER
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _moods.map((mood) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: mood["color"],
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (mood["color"] as Color)
                                          .withAlpha(60),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      mood["icon"],
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      mood["name"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BLOGS HEADER
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Blogs",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "See More",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _brandAccent, // Swapped accent
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // BLOG CARDS LIST
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: const [
                              BlogCard(
                                title: "Building a Deep Connection with the Qur'an Daily",
                                author: "Ustadh Ali",
                                date: "Oct 12",
                                image: "assets/images/blog_sample_1.png",
                                category: "Reflection",
                              ),
                              BlogCard(
                                title: "Finding Spiritual Focus During Busy Mornings",
                                author: "Dr. Sara",
                                date: "Oct 10",
                                image: "assets/images/blog_sample_2.png",
                                category: "Lifestyle",
                              ),
                              BlogCard(
                                title: "The Importance of Mindful Recitation",
                                author: "Yasir Q.",
                                date: "Oct 09",
                                image: "assets/images/blog_sample_1.png",
                                category: "Learning",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30), // End spacing
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(220),
        border: Border.all(color: Colors.black.withAlpha(15)),
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }
}
