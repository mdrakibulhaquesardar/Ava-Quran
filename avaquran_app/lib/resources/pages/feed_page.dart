import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/trend_video_card_widget.dart';
import '/resources/widgets/blog_card_widget.dart';
import '/resources/pages/peoples_page.dart';

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
  final PageController _pageController = PageController();

  final List<Map<String, String>> _mockUsers = [
    {
      "name": "Sarah Ahmed",
      "bio": "Daily Quran Reflections & Journaling",
      "image": "assets/images/avatar_1.png",
      "followers": "1.2k",
    },
    {
      "name": "Zaid Al-Farooq",
      "bio": "Community Leader & Mentor",
      "image": "assets/images/avatar_2.png",
      "followers": "850",
    },
    {
      "name": "Aisha Rahman",
      "bio": "Islamic Art & Modesty Designer",
      "image": "assets/images/avatar_1.png",
      "followers": "2.4k",
    },
    {
      "name": "Omar H.",
      "bio": "Software Developer by day, Qari by night",
      "image": "assets/images/avatar_2.png",
      "followers": "1.5k",
    },
  ];

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
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
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
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedNavTabIndex = index);
                    },
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // TAB 0: FEED CONTENT
                      SingleChildScrollView(
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

                      // TAB 1: PEOPLES
                      _buildPeoplesView(),

                      // TAB 2: VIDEOS
                      _buildPlaceholderView(
                          "Videos", Icons.play_circle_outline),

                      // TAB 3: BLOGS
                      _buildPlaceholderView("Blogs", Icons.article_outlined),

                      // TAB 4: PLAYLISTS
                      _buildPlaceholderView(
                          "Playlists", Icons.playlist_play_outlined),
                    ],
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

  Widget _buildPeoplesView() {
    return Column(
      children: [
        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search people to follow...",
                hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search, color: _brandAccent, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),

        // LIST CONTENT
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: _mockUsers.length,
            itemBuilder: (context, index) {
              final user = _mockUsers[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, String> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _brandAccent.withAlpha(50), width: 2),
              image: DecorationImage(
                image: AssetImage(user["image"]!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user["bio"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${user["followers"]} followers",
                  style: TextStyle(
                    fontSize: 12,
                    color: _brandAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _brandAccent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _brandAccent.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "Follow",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: _brandAccent.withAlpha(60)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Discover content related to $title",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}
