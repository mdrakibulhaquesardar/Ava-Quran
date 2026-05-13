import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../app/networking/api_service.dart';

class PeoplesPage extends NyStatefulWidget {
  static RouteView path = ("/peoples", (_) => PeoplesPage());

  PeoplesPage({super.key}) : super(child: () => _PeoplesPageState());
}

class _PeoplesPageState extends NyPage<PeoplesPage> {
  final Color _brandAccent = const Color(0xFF267B92);

  // DISCOVER USERS & FOLLOW STATE
  late ScrollController _peoplesScrollController;
  List<dynamic> _discoverUsers = [];
  bool _isLoadingUsers = true;
  bool _isFetchingMoreUsers = false;
  int _usersPage = 1;
  bool _usersHasMore = true;

  @override
  get init => () {
    _peoplesScrollController = ScrollController()..addListener(_onPeoplesScroll);
    _fetchDiscoverUsers();
  };

  @override
  void dispose() {
    _peoplesScrollController.dispose();
    super.dispose();
  }

  @override
  bool get stateManaged => false;

  void _onPeoplesScroll() {
    if (_peoplesScrollController.position.pixels >= _peoplesScrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingUsers && !_isFetchingMoreUsers && _usersHasMore) {
        _fetchMoreDiscoverUsers();
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
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND TEXTURE
          Positioned.fill(
            child: Image.asset(
              "assets/images/pattern_light_soft.png",
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.60),
            ),
          ),

          // 2. MAIN PAGE CONTENT
          SafeArea(
            child: Column(
              children: [
                // CUSTOM HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                        ),
                      ),
                      
                      const Text(
                        "Community",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(width: 40),
                    ],
                  ),
                ),

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

                // DYNAMIC LIST CONTENT
                Expanded(
                  child: _buildPeoplesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeoplesList() {
    if (_isLoadingUsers) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: 8,
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

    return RefreshIndicator(
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
}
