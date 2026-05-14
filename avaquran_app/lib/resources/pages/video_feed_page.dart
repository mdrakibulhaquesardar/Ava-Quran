import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/networking/api_service.dart';
import '../../app/networking/quran_api_service.dart';
import '../widgets/ken_burns_media_item.dart';
import '/app/models/user.dart';
import '/config/storage_keys.dart';

class VideoFeedPage extends NyStatefulWidget {
  static RouteView path = ("/video-feed", (_) => VideoFeedPage());

  VideoFeedPage({super.key}) : super(child: () => _VideoFeedPageState());
}

class _VideoFeedPageState extends NyPage<VideoFeedPage> {
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;
  late PageController _pageController;

  List<dynamic> _feedItems = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _selectedMood = "";
  String _feedType = "general"; // New: tracking the source of the feed (general, most_loved, etc.)

  // 1. UX UX & Tracking enhancements
  Timer? _viewTimer;
  final Set<String> _viewedKeysCache = {};
  bool _isAudioPaused = false;
  
  // Streak tracking variables
  int _secondsWatchedThisSession = 0;
  bool _streakUpdatedThisSession = false;
  Timer? _sessionTimer;
  static const int _streakThresholdSeconds = 3; // 3 seconds for testing (was 600)

  @override
  get init => () async {
        _audioPlayer = AudioPlayer();
        
        final dynamic data = widget.data();
        String? initialKey;
        List<dynamic>? preloaded;

        if (data is String) {
          _selectedMood = data;
        } else if (data is Map) {
          _selectedMood = data['mood'] ?? "";
          _feedType = data['feedType'] ?? "general";
          initialKey = data['initialVerseKey'];
          if (data['preloadedFeed'] is List) {
            preloaded = List.from(data['preloadedFeed']);
          }
        }

        // If preloaded feed array supplied (e.g. Most Loved Carousel), hydrate directly without initial api wait
        if (preloaded != null && preloaded.isNotEmpty) {
          int targetIdx = 0;
          if (initialKey != null) {
            final idx = preloaded.indexWhere((item) => item["verseKey"] == initialKey);
            if (idx != -1) targetIdx = idx;
          }
          
          _currentIndex = targetIdx;
          _feedItems = preloaded;
          _pageController = PageController(initialPage: targetIdx);
          _isLoading = false;
          
          for (var item in _feedItems) {
            if (item["isViewed"] == true && item["verseKey"] != null) {
              _viewedKeysCache.add(item["verseKey"]);
            }
          }
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
             _playCurrentTrack();
          });
        } else {
          _pageController = PageController();
          await _fetchInitialFeed();
        }

        // Start session timer to track total watch time
        _startSessionTimer();
      };

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isAudioPaused && _feedItems.isNotEmpty && mounted) {
        _secondsWatchedThisSession++;
        
        // Check if threshold reached
        if (_secondsWatchedThisSession >= _streakThresholdSeconds && !_streakUpdatedThisSession) {
          _triggerStreakUpdate();
          _streakUpdatedThisSession = true;
        }
      }
    });
  }

  Future<void> _fetchInitialFeed() async {
    setState(() {
      _isLoading = true;
      _feedItems.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final response = await ApiService().fetchFeed(
        mood: _selectedMood,
        page: _currentPage,
        limit: 10,
      );

      if (response != null && response['data'] != null) {
        setState(() {
          _feedItems = List.from(response['data']);
          _hasMore = response['meta']?['hasMore'] ?? true;
          
          // Initialize local session viewed state based on backend history
          for (var item in _feedItems) {
            if (item["isViewed"] == true && item["verseKey"] != null) {
              _viewedKeysCache.add(item["verseKey"]);
            }
          }
        });
        if (_feedItems.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
             _playCurrentTrack();
          });
        }
      }
    } catch (e) {
      NyLogger.error("Error fetching initial feed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isFetchingMore || !_hasMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final int nextPage = _currentPage + 1;
      dynamic response;
       
      if (_feedType == "most_loved") {
        response = await ApiService().fetchMostLoved(
          page: nextPage,
          limit: 10,
        );
      } else {
        response = await ApiService().fetchFeed(
          mood: _selectedMood,
          page: nextPage,
          limit: 10,
        );
      }

      if (response != null && response['data'] != null) {
        final List<dynamic> newItems = response['data'];
        if (newItems.isNotEmpty) {
          setState(() {
            _feedItems.addAll(newItems);
            _currentPage = nextPage;
            _hasMore = response['meta']?['hasMore'] ?? true;
            
            for (var item in newItems) {
              if (item["isViewed"] == true && item["verseKey"] != null) {
                _viewedKeysCache.add(item["verseKey"]);
              }
            }
          });
        } else {
          setState(() {
            _hasMore = false;
          });
        }
      }
    } catch (e) {
      NyLogger.error("Error fetching next page: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _sessionTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playCurrentTrack() async {
    if (_feedItems.isEmpty || _currentIndex >= _feedItems.length) return;

    // Reset active view timer for the new track
    _viewTimer?.cancel();

    try {
      await _audioPlayer.stop();
      final item = _feedItems[_currentIndex];
      final String? audioUrl = item["audioUrl"];
      final String? key = item["verseKey"];
      
      setState(() {
        _isAudioPaused = false;
      });

      if (audioUrl != null && audioUrl.isNotEmpty) {
        await _audioPlayer.play(UrlSource(audioUrl));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(0.4); // Ambient background volume
        
        // 2. START VIEW TIMER: ONLY count view if stayed >= 3 seconds
        if (key != null) {
          _viewTimer = Timer(const Duration(seconds: 3), () {
            _onTrackRetainedForThreeSeconds(key, _currentIndex);
          });
        }
      }
    } catch (e) {
      debugPrint("Error playing audio track: $e");
    }
  }

  void _onTrackRetainedForThreeSeconds(String key, int indexAtTime) {
    // Verify that we are still viewing the SAME track
    if (!mounted || _currentIndex != indexAtTime) return;
    
    // Avoid duplicative API calls per session using local cache
    if (_viewedKeysCache.contains(key)) return;

    _viewedKeysCache.add(key);
    
    setState(() {
      // Reflect instantly in local UI
      if (_currentIndex < _feedItems.length) {
        final item = _feedItems[_currentIndex];
        item["isViewed"] = true;
        
        // Optimistically boost view count locally!
        final meta = item["videoMeta"] ?? {};
        final int views = meta["views"] ?? 0;
        meta["views"] = views + 1;
        item["videoMeta"] = meta;
      }
    });

    // Fire interaction log in the background
    _logInteraction(key, "view");
    
    // Note: Streak update now handled by session timer after 10 minutes
  }

  Future<void> _triggerStreakUpdate() async {
    if (Auth.data() == null) return;
    
    try {
      // 1. Log activity to Quran Foundation server
      final String today = DateTime.now().toIso8601String().split('T')[0];
      await QuranApiService().logActivity(
        date: today,
        seconds: _secondsWatchedThisSession,
      );

      // 2. Fetch fresh streak days from Quran Foundation
      final streakResponse = await QuranApiService().fetchCurrentStreakDays();
      if (streakResponse != null && streakResponse['days'] != null) {
        final int newStreak = streakResponse['days'];
        
        // Get current local user to compare
        final dynamic authData = Auth.data();
        if (authData != null) {
          final user = User.fromJson(authData is String ? jsonDecode(authData) : authData);
          if (newStreak > user.currentStreak) {
            // Streak increased! Show celebration
            showToastSuccess(
              title: "Daily Streak!",
              description: "You're on a $newStreak day streak! Keep it up.",
            );
            
            // Sync local user object
            user.currentStreak = newStreak;
            await Auth.authenticate(data: user.toJson());
            await StorageKeysConfig.user.save(jsonEncode(user.toJson()));
          }
        }
      }
      
      // 3. Fallback: Also update our local backend if needed (optional, but keep it sync'd)
      await ApiService().updateStreak();
      
    } catch (e) {
      NyLogger.error("Streak update on Quran server failed: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (_feedItems.isEmpty) return;
    
    HapticFeedback.lightImpact();
    
    try {
      if (_isAudioPaused) {
        await _audioPlayer.resume();
        setState(() {
          _isAudioPaused = false;
        });
      } else {
        await _audioPlayer.pause();
        setState(() {
          _isAudioPaused = true;
        });
      }
    } catch (e) {
      debugPrint("Error toggling play/pause: $e");
    }
  }

  Future<void> _handleLike(int index) async {
    if (index < 0 || index >= _feedItems.length) return;
    final item = _feedItems[index];
    final String? key = item["verseKey"];
    if (key == null) return;

    HapticFeedback.mediumImpact();
    final bool currentLoved = item["isLoved"] ?? false;

    setState(() {
      // Optimistic State Update
      item["isLoved"] = !currentLoved;
      
      final meta = item["videoMeta"] ?? {};
      final int rawLikes = meta["likes"] ?? 0;
      meta["likes"] = currentLoved ? (rawLikes > 0 ? rawLikes - 1 : 0) : rawLikes + 1;
      item["videoMeta"] = meta;
    });

    try {
      await ApiService().trackInteraction(ayahKey: key, interactionType: currentLoved ? "unlike" : "love");
    } catch (e) {
      // Silently rollback if network fails
      if (mounted) {
        setState(() {
          item["isLoved"] = currentLoved;
          final meta = item["videoMeta"] ?? {};
          final int rawLikes = meta["likes"] ?? 0;
          meta["likes"] = currentLoved ? rawLikes + 1 : (rawLikes > 0 ? rawLikes - 1 : 0);
          item["videoMeta"] = meta;
        });
      }
    }
  }

  Future<void> _handleSave(int index) async {
    if (index < 0 || index >= _feedItems.length) return;
    final item = _feedItems[index];
    final String? key = item["verseKey"];
    if (key == null) return;

    HapticFeedback.mediumImpact();
    final bool isCurrentlySaved = item["isSaved"] ?? false;

    // Case: Unsaving (simply toggle off for now or track)
    if (isCurrentlySaved) {
      setState(() {
        item["isSaved"] = false;
      });
      try {
        await ApiService().trackInteraction(ayahKey: key, interactionType: "unsave");
      } catch (e) {}
      return;
    }

    // Case: Saving (Optimistic Update)
    setState(() {
      item["isSaved"] = true;
    });

    try {
      final colsRes = await ApiService().fetchCollections();
      List<dynamic> userCols = colsRes != null ? List.from(colsRes) : [];

      if (userCols.isEmpty) {
        if (mounted) _showCollectionsSelectionSheet(item, index, userCols);
      } else if (userCols.length == 1) {
        // Directly save to the unique existing folder
        final col = userCols.first;
        await ApiService().addAyahToCollection(collectionId: col['id'].toString(), ayahKey: key);
        if (mounted) {
          showToastSuccess(description: "Added to '${col['title']}'");
        }
      } else {
        if (mounted) _showCollectionsSelectionSheet(item, index, userCols);
      }
      
      ApiService().trackInteraction(ayahKey: key, interactionType: "save");
    } catch (e) {
      NyLogger.error("Error during collection save flow: $e");
      if (mounted) {
        setState(() {
          item["isSaved"] = false;
        });
      }
    }
  }

  void _showCollectionsSelectionSheet(dynamic item, int index, List<dynamic> initialCollections) {
    final String? key = item["verseKey"];
    if (key == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF191619), // Pure rich warm charcoal
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withAlpha(15), width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const Text(
                  "Save to Collection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (initialCollections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Create folders to organize spiritual reminders.",
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: initialCollections.length,
                      itemBuilder: (c, i) {
                        final col = initialCollections[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder_open_rounded, color: Colors.white70, size: 20),
                          ),
                          title: Text(
                            col['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              await ApiService().addAyahToCollection(collectionId: col['id'].toString(), ayahKey: key);
                              if (mounted) {
                                showToastSuccess(description: "Added to '${col['title']}'");
                              }
                            } catch (e) {
                               NyLogger.error("Failed inline save: $e");
                            }
                          },
                        );
                      },
                    ),
                  ),
                
                const Divider(color: Colors.white12, height: 24),
                
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _showInlineCreateFlow(key);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Color(0xFFEC4899), size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "New Collection",
                          style: TextStyle(
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInlineCreateFlow(String verseKey) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201E21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("New Collection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "e.g. Guided Peace",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withAlpha(10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final newCol = await ApiService().createCollection(title: text);
                if (newCol != null) {
                  await ApiService().addAyahToCollection(
                    collectionId: newCol['id'].toString(),
                    ayahKey: verseKey
                  );
                  if (mounted) {
                    showToastSuccess(description: "Added to new '$text' folder");
                  }
                }
              } catch(e) {
                NyLogger.error("Inline folder creation failed: $e");
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> _handleShare(int index) async {
    if (index < 0 || index >= _feedItems.length) return;
    final item = _feedItems[index];
    final String? key = item["verseKey"];
    if (key == null) return;

    HapticFeedback.lightImpact();
    final String translation = item["translation"] ?? "";
    final String reference = "Surah ${item["chapterNumber"] ?? "?"}:${item["verseNumber"] ?? "?"}";

    // 1. Optimistically boost share count instantly
    setState(() {
      final meta = item["videoMeta"] ?? {};
      final int currentShares = meta["shares"] ?? 0;
      meta["shares"] = currentShares + 1;
      item["videoMeta"] = meta;
    });

    // 2. Fire analytics logging to backend in background
    _logInteraction(key, "share");
    
    // 3. Trigger System Share Dialog via SharePlus
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: "\"$translation\"\n\nQuran $reference\n\nListen to this beautiful reminder on Ava Quran App.",
        ),
      );
    } catch (e) {
      debugPrint("Failed sharing item: $e");
    }
  }

  Future<void> _logInteraction(String? key, String type) async {
    if (key == null || key.isEmpty) return;
    try {
      await ApiService().trackInteraction(ayahKey: key, interactionType: type);
    } catch (e) {
      debugPrint("Error logging interaction $type for $key: $e");
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. VERTICAL PAGE VIEW BUILDER OR LOADER
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                )
              : _feedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sentiment_dissatisfied, color: Colors.white38, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            "No moments found for this selection.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Go Back"),
                          ),
                        ],
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _feedItems.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        _playCurrentTrack();

                        // Smart Preload trigger when reaching last 3 items
                        if (index >= _feedItems.length - 3) {
                          _fetchNextPage();
                        }
                      },
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              // Calculate scale and opacity based on distance from center
                              value = (1 - (value.abs() * 0.12)).clamp(0.0, 1.0);
                            } else {
                              // Initial state before dimensions are ready
                              value = (index == _currentIndex) ? 1.0 : 0.88;
                            }
                            
                            return Transform.scale(
                              scale: Curves.easeOutCubic.transform(value),
                              child: Opacity(
                                opacity: Curves.easeInQuad.transform(value),
                                child: child,
                              ),
                            );
                          },
                          child: _buildVideoItem(index),
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
                    child: Text(
                      _selectedMood.isNotEmpty
                          ? "#${_selectedMood.toUpperCase()}"
                          : "Ava Moments",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balancing layout Spacer
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVideoItem(int index) {
    final item = _feedItems[index];
    final background = item["videoBackground"];
    final meta = item["videoMeta"];
    
    final String imageUrl = background?["url"] ?? "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80";
    final String arabic = item["textUthmani"] ?? "";
    final String quote = item["translation"] ?? "";
    final String reference = "Surah ${item["chapterNumber"] ?? "?"}:${item["verseNumber"] ?? "?"}";
    
    return KenBurnsMediaItem(
      key: ValueKey("${item["id"] ?? index}"),
      imageUrl: imageUrl,
      arabic: arabic,
      quote: quote,
      author: reference,
      isActive: _currentIndex == index,
      isPaused: _isAudioPaused,
      isViewed: item["isViewed"] ?? false,
      isLoved: item["isLoved"] ?? false,
      isSaved: item["isSaved"] ?? false,
      aiInsight: item["aiInsight"],
      moodTag: item["moodTag"],
      likes: _formatCounter(meta?["likes"]),
      views: _formatCounter(meta?["views"]),
      shares: _formatCounter(meta?["shares"]),
      onLikeTap: () => _handleLike(index),
      onSaveTap: () => _handleSave(index),
      onShareTap: () => _handleShare(index),
      onMainTap: _togglePlayPause,
    );
  }
}
