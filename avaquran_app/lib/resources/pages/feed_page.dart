import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/trend_video_card_widget.dart';

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

  final List<Map<String, dynamic>> _topics = [
    {
      "name": "Clothing",
      "icon": Icons.checkroom,
      "color": const Color(0xFFD5C69F),
    },
    {
      "name": "Death",
      "icon": Icons.notifications_active,
      "color": const Color(0xFF529CFF),
    },
    {"name": "Justice", "icon": Icons.gavel, "color": const Color(0xFFE9C56D)},
    {
      "name": "Gambling",
      "icon": Icons.casino,
      "color": const Color(0xFFEAD177),
    },
    {
      "name": "Life Hereafter",
      "icon": Icons.sync_alt,
      "color": const Color(0xFFB3A37B),
    },
    {
      "name": "Marriage",
      "icon": Icons.favorite_border,
      "color": const Color(0xFFDACFBD),
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

                        // EXPLORE TOPICS SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Explore Topics",
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
                                "Discover videos, blogs, playlists based on topic.",
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
                            children: _topics.map((topic) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: topic["color"],
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (topic["color"] as Color)
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
                                      topic["icon"],
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      topic["name"],
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
