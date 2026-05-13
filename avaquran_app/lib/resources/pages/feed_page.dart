import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/trend_video_card_widget.dart';
import '/resources/widgets/blog_card_widget.dart';
import '/resources/pages/profile_page.dart';
import '/resources/pages/blog_details_page.dart';
import '/resources/pages/video_feed_page.dart';
import '/resources/pages/create_blog_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
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

  List<dynamic> _mostLovedVideos = [];
  bool _isLoadingLoved = true;

  // DYNAMIC BLOGS STATE
  late ScrollController _blogsScrollController;
  List<dynamic> _blogItems = [];
  bool _isLoadingBlogs = true;
  bool _isFetchingMoreBlogs = false;
  int _blogsPage = 1;
  bool _blogsHasMore = true;
  int _selectedSubTabIndex = 0; // 0 for Discover, 1 for Following

  // DISCOVER USERS & FOLLOW STATE
  late ScrollController _peoplesScrollController;
  List<dynamic> _discoverUsers = [];
  bool _isLoadingUsers = true;
  bool _isFetchingMoreUsers = false;
  int _usersPage = 1;
  bool _usersHasMore = true;

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
    _peoplesScrollController = ScrollController()..addListener(_onPeoplesScroll);
    _blogsScrollController = ScrollController()..addListener(_onBlogsScroll);
    _fetchMostLovedData();
    _fetchDiscoverUsers();
    _fetchBlogsData();
  };

  @override
  void dispose() {
    _peoplesScrollController.dispose();
    _blogsScrollController.dispose();
    super.dispose();
  }

  void _onPeoplesScroll() {
    if (_peoplesScrollController.position.pixels >= _peoplesScrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingUsers && !_isFetchingMoreUsers && _usersHasMore) {
        _fetchMoreDiscoverUsers();
      }
    }
  }
  void _onBlogsScroll() {
    if (_blogsScrollController.position.pixels >= _blogsScrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingBlogs && !_isFetchingMoreBlogs && _blogsHasMore) {
        _fetchMoreBlogsData();
      }
    }
  }

  Future<void> _fetchBlogsData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingBlogs = true;
      _blogsPage = 1;
    });
    try {
      final response = await ApiService().fetchBlogs(page: _blogsPage, limit: 10);
      if (response != null && response['items'] != null && mounted) {
        setState(() {
          _blogItems = List.from(response['items']);
          _blogsHasMore = response['hasMore'] ?? false;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching blogs: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBlogs = false;
        });
      }
    }
  }

  Future<void> _fetchMoreBlogsData() async {
    if (!mounted) return;
    setState(() {
      _isFetchingMoreBlogs = true;
    });
    try {
      final nextPage = _blogsPage + 1;
      final response = await ApiService().fetchBlogs(page: nextPage, limit: 10);
      if (response != null && response['items'] != null && mounted) {
        setState(() {
          _blogsPage = nextPage;
          _blogItems.addAll(response['items']);
          _blogsHasMore = response['hasMore'] ?? false;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching more blogs: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMoreBlogs = false;
        });
      }
    }
  }

  Future<void> _fetchDiscoverUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingUsers = true;
      _usersPage = 1;
    });
    try {
      final response = await ApiService().fetchDiscoverUsers(page: _usersPage, limit: 20);
      if (response != null && response['items'] != null && mounted) {
        setState(() {
          _discoverUsers = List.from(response['items']);
          _usersHasMore = response['hasMore'] ?? false;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching discover users: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _fetchMoreDiscoverUsers() async {
    if (!mounted) return;
    setState(() {
      _isFetchingMoreUsers = true;
    });
    try {
      final nextPage = _usersPage + 1;
      final response = await ApiService().fetchDiscoverUsers(page: nextPage, limit: 20);
      if (response != null && response['items'] != null && mounted) {
        setState(() {
          _usersPage = nextPage;
          _discoverUsers.addAll(response['items']);
          _usersHasMore = response['hasMore'] ?? false;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching more discover users: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMoreUsers = false;
        });
      }
    }
  }

  Future<void> _toggleFollow(int index) async {
    final user = _discoverUsers[index];
    final String userId = user["id"].toString();
    final bool isCurrentlyFollowing = user["isFollowing"] ?? false;
    final int currentFollowers = user["followersCount"] ?? 0;

    HapticFeedback.lightImpact();

    // Optimistic UI Updates
    setState(() {
      user["isFollowing"] = !isCurrentlyFollowing;
      user["followersCount"] = isCurrentlyFollowing
          ? (currentFollowers - 1).clamp(0, 99999999)
          : currentFollowers + 1;
    });

    try {
      if (isCurrentlyFollowing) {
        await ApiService().unfollowUser(targetUserId: userId);
      } else {
        await ApiService().followUser(targetUserId: userId);
      }
    } catch (e) {
      // Revert state atomically on API fail
      if (mounted) {
        setState(() {
          user["isFollowing"] = isCurrentlyFollowing;
          user["followersCount"] = currentFollowers;
        });
        showToastDanger(
          description: "Connection dropped, please try again.",
        );
      }
    }
  }

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
    return PopScope(
      canPop: _selectedNavTabIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_selectedNavTabIndex != 0) {
          setState(() {
            _selectedNavTabIndex = 0;
          });
        }
      },
      child: Scaffold(
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
                          _buildCircleIconButton(
                            Icons.add,
                            onTap: () async {
                              final published = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateBlogPage()),
                              );
                              if (published == true) {
                                _fetchBlogsData();
                              }
                            },
                          ),
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
                          setState(() {
                            _selectedNavTabIndex = index;
                          });
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
                  child: IndexedStack(
                    index: _selectedNavTabIndex,
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
                          child: _isLoadingBlogs
                              ? Column(
                                  children: List.generate(
                                    3,
                                    (index) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 109,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : _blogItems.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          "No articles shared yet.",
                                          style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: _blogItems
                                          .take(3)
                                          .map((blog) => BlogCard(blog: blog))
                                          .toList(),
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
    if (_isLoadingUsers) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 87,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    if (_discoverUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: _brandAccent.withAlpha(60)),
            const SizedBox(height: 16),
            Text(
              "No community members found.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchDiscoverUsers,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            )
          ],
        ),
      );
    }

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
          child: RefreshIndicator(
            onRefresh: _fetchDiscoverUsers,
            child: ListView.builder(
              controller: _peoplesScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _discoverUsers.length + (_isFetchingMoreUsers ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _discoverUsers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FBAB3)),
                        ),
                      ),
                    ),
                  );
                }
                final user = _discoverUsers[index];
                return _buildUserCard(user, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(dynamic user, int index) {
    final bool isFollowing = user["isFollowing"] ?? false;
    final String avatar = user["avatar"] ?? "";
    final String name = user["name"] ?? "Reflector";
    final String bio = user["bio"] ?? "Quran Learner & Reflecter";

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
          // Network Avatar or Fallback Multiavatar
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
              child: avatar.startsWith("http")
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => SvgPicture.string(
                        multiavatar(name),
                        fit: BoxFit.cover,
                      ),
                    )
                  : SvgPicture.string(
                      multiavatar(name),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Text Details Block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
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
                  "${_formatCounter(user["followersCount"] ?? 0)} followers",
                  style: TextStyle(
                    fontSize: 12,
                    color: _brandAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Beautiful Interactive Follow Toggle Button
          GestureDetector(
            onTap: () => _toggleFollow(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isFollowing ? Colors.transparent : _brandAccent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFollowing ? Colors.grey.shade300 : _brandAccent,
                  width: 1.5,
                ),
                boxShadow: isFollowing
                    ? []
                    : [
                        BoxShadow(
                          color: _brandAccent.withAlpha(50),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Text(
                isFollowing ? "Following" : "Follow",
                style: TextStyle(
                  color: isFollowing ? Colors.grey.shade700 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
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
    if (_isLoadingBlogs) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: index == 0 ? 220 : 109,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      );
    }

    if (_blogItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: _brandAccent.withAlpha(60)),
            const SizedBox(height: 16),
            Text(
              "No community blogs published yet.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchBlogsData,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Feed"),
            )
          ],
        ),
      );
    }

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

        // SCROLLABLE BLOGS CONTENT
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchBlogsData,
            child: ListView.builder(
              controller: _blogsScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _blogItems.length + (_isFetchingMoreBlogs ? 1 : 0),
              itemBuilder: (context, index) {
                // Bottom pagination loader
                if (index == _blogItems.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FBAB3)),
                        ),
                      ),
                    ),
                  );
                }

                final blog = _blogItems[index];

                // First item: Hero spotlight followed by header
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBlogHeroPost(blog),
                      const SizedBox(height: 25),
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
                    ],
                  );
                }

                // Remaining items
                return BlogCard(blog: blog);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlogHeroPost(dynamic blog) {
    final String id = blog["id"]?.toString() ?? UniqueKey().toString();
    final String title = blog["title"] ?? "";
    final String author = blog["user"]?["name"] ?? "Ava User";
    final String? thumbUrl = blog["thumbnailUrl"];

    return GestureDetector(
      onTap: () => routeTo(BlogDetailsPage.path, data: blog),
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
              // Network-optimised Hero spotlight cover
              Hero(
                tag: "blog-image-$id",
                child: (thumbUrl != null && thumbUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: thumbUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFEBF5F7),
                          child: const Icon(Icons.article_outlined, color: Color(0xFF267B92), size: 48),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFEBF5F7),
                        child: const Icon(Icons.article_outlined, color: Color(0xFF267B92), size: 48),
                      ),
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
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "By $author",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 20),
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
