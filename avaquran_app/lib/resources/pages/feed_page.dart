import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/trend_video_card_widget.dart';
import '/resources/widgets/blog_card_widget.dart';
import '/resources/pages/profile_page.dart';
import '/resources/pages/blog_details_page.dart';
import '/resources/pages/video_feed_page.dart';
import '../../app/networking/api_service.dart';
import 'package:shimmer/shimmer.dart';

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
  int _selectedBlogCategoryIndex = 0;
  final List<String> _blogCategories = ["All", "Reflection", "Lifestyle", "Learning", "History", "Kids"];

  List<dynamic> _mostLovedVideos = [];
  bool _isLoadingLoved = true;

  final List<Map<String, String>> _blogs = [
    {
      "title": "Building a Deep Connection with the Qur'an Daily",
      "author": "Ustadh Ali",
      "date": "Oct 12",
      "image": "assets/images/blog_sample_1.png",
      "category": "Reflection",
    },
    {
      "title": "Finding Spiritual Focus During Busy Mornings",
      "author": "Dr. Sara",
      "date": "Oct 10",
      "image": "assets/images/blog_sample_2.png",
      "category": "Lifestyle",
    },
    {
      "title": "The Importance of Mindful Recitation",
      "author": "Yasir Q.",
      "date": "Oct 09",
      "image": "assets/images/blog_sample_1.png",
      "category": "Learning",
    },
    {
      "title": "Prophetic Habits for Balanced Physical Health",
      "author": "Imran M.",
      "date": "Oct 05",
      "image": "assets/images/blog_sample_2.png",
      "category": "Lifestyle",
    },
  ];
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
  get init => () {
    _fetchMostLovedData();
  };

  Future<void> _fetchMostLovedData() async {
    setState(() {
      _isLoadingLoved = true;
    });
    try {
      final response = await ApiService().fetchMostLoved(limit: 10);
      if (response != null && response['data'] != null) {
        setState(() {
          _mostLovedVideos = List.from(response['data']);
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching most loved data: $e");
    } finally {
      setState(() {
        _isLoadingLoved = false;
      });
    }
  }

  String _formatCounter(dynamic count) {
    if (count == null) return "0";
    final int numCount = count is int ? count : int.tryParse(count.toString()) ?? 0;
    if (numCount >= 1000000) {
      return "${(numCount / 1000000).toStringAsFixed(1)}M";
    }
    if (numCount >= 1000) {
      return "${(numCount / 1000).toStringAsFixed(1)}K";
    }
    return numCount.toString();
  }

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
                      Image.asset("assets/images/Icon_text.png", height: 45),
                      Row(
                        children: [
                          _buildCircleIconButton(Icons.add),
                          const SizedBox(width: 12),
                          _buildCircleIconButton(
                            Icons.notifications_none_outlined,
                          ),
                          const SizedBox(width: 12),
                          _buildCircleIconButton(
                            Icons.person_2,
                            onTap: () => routeTo(ProfilePage.path),
                          ),
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

                        // HORIZONTAL VIDEO LIST (DYNAMIC REEL CAROUSEL)
                        SizedBox(
                          height: 190,
                          child: _isLoadingLoved
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: 4,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 150,
                                        margin: const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : _mostLovedVideos.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No highlights available yet",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: _mostLovedVideos.length,
                                      itemBuilder: (context, index) {
                                        final item = _mostLovedVideos[index];
                                        final background = item["videoBackground"];
                                        final meta = item["videoMeta"];

                                        final String translation = item["translation"] ?? "Beautiful Reflection";
                                        final String imageUrl = background?["url"] ?? "";
                                        final int durationSeconds = meta?["duration"] ?? 30;
                                        final int likes = meta?["likes"] ?? 0;
                                        final bool isLoved = item["isLoved"] ?? false;

                                        return TrendVideoCard(
                                          title: translation,
                                          image: imageUrl,
                                          duration: "${durationSeconds}s",
                                          likes: _formatCounter(likes),
                                          isLoved: isLoved,
                                          onTap: () {
                                            // Navigate directly to the dynamic reel viewer, passing state and index key context!
                                            routeTo(
                                              VideoFeedPage.path,
                                              data: {
                                                'initialVerseKey': item["verseKey"],
                                                'preloadedFeed': _mostLovedVideos,
                                              },
                                            );
                                          },
                                        );
                                      },
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
                              return GestureDetector(
                                onTap: () => routeTo(VideoFeedPage.path, data: mood["name"].toString().toLowerCase()),
                                child: Container(
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
                      _buildBlogsView(),

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

  Widget _buildCircleIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(220),
          border: Border.all(color: Colors.black.withAlpha(15)),
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
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
              color: Colors.white,
              border: Border.all(color: _brandAccent.withAlpha(50), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SvgPicture.string(
                multiavatar(user["name"]!),
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

  Widget _buildBlogsView() {
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
                hintText: "Search articles & lessons...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search, color: _brandAccent, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),

        // CATEGORIES SELECTOR
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _blogCategories.length,
            itemBuilder: (context, index) {
              bool isSelected = index == _selectedBlogCategoryIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBlogCategoryIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _brandAccent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _brandAccent : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _brandAccent.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    _blogCategories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // SCROLLABLE BLOGS CONTENT
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              // HERO SPOTLIGHT
              _buildBlogHeroPost(),
              
              const SizedBox(height: 25),
              
              // RECENT POSTS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Articles",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "View all",
                      style: TextStyle(
                        color: _brandAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // DYNAMIC LIST GENERATOR
              ..._blogs.map((blog) => BlogCard(
                    title: blog["title"]!,
                    author: blog["author"]!,
                    date: blog["date"]!,
                    image: blog["image"]!,
                    category: blog["category"]!,
                  )).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlogHeroPost() {
    return GestureDetector(
      onTap: () => routeTo(BlogDetailsPage.path, data: {
        'title': "Cultivating a Life of Gratitude Through Divine Teachings",
        'author': "Mufti Menk",
        'date': "Today",
        'image': "assets/images/blog_sample_1.png",
        'category': "Featured",
      }),
      child: Container(
        width: double.infinity,
        height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/blog_sample_1.png",
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(0),
                      Colors.black.withAlpha(160),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "FEATURED",
                      style: TextStyle(
                        color: _brandAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Cultivating a Life of Gratitude Through Divine Teachings",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 14, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "By Mufti Menk",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
