import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/networking/api_service.dart';
import '/resources/pages/video_feed_page.dart';

class CollectionDetailsPage extends NyStatefulWidget {
  final String collectionId;
  final String collectionTitle;

  CollectionDetailsPage({
    super.key,
    required this.collectionId,
    required this.collectionTitle,
  }) : super(child: () => _CollectionDetailsPageState());
}

class _CollectionDetailsPageState extends NyPage<CollectionDetailsPage> {
  final Color _brandAccent = const Color(0xFF267B92);

  List<dynamic> _reels = [];
  bool _isLoading = true;

  @override
  get init => () {
    _loadCollectionContent();
  };

  Future<void> _loadCollectionContent() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await ApiService().fetchCollectionAyahs(collectionId: widget.collectionId);
      if (res != null && res['items'] != null && mounted) {
        setState(() {
          _reels = List.from(res['items']);
        });
      }
    } catch (e) {
      NyLogger.error("Failed to load collection content: $e");
      showToastDanger(description: "Couldn't fetch your saved items.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Image.asset(
              "assets/images/pattern_light_soft.png",
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.03),
            ),
          ),

          // Content view
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFF8FBFA).withAlpha(230),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: Text(
                  widget.collectionTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // Subtitle Info Block
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _brandAccent.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bookmark_rounded, color: _brandAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Saved Reminders",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${_reels.length} reels saved to folder",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Divider(indent: 16, endIndent: 16, height: 1)),

              if (_isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_brandAccent),
                    ),
                  ),
                )
              else if (_reels.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_collection_outlined, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "This collection is empty",
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(4.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 0.65, // Rectangular social portrait ratio
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _reels[index];
                        return _buildReelGridItem(item, index);
                      },
                      childCount: _reels.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReelGridItem(dynamic item, int index) {
    final String? imgUrl = item['videoBackground']?['url'];
    final String key = item['verseKey'] ?? '';
    final String mood = item['moodTag'] ?? 'reflection';

    return GestureDetector(
      onTap: () {
        // Route directly to VideoFeedPage pre-populating the cached reels
        routeTo(
          VideoFeedPage.path,
          data: {
            'preloadedFeed': _reels,
            'initialVerseKey': key,
            'mood': mood,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image Cover
            Positioned.fill(
              child: imgUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade100),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    )
                  : Container(color: Colors.grey.shade100),
            ),

            // Small glass-overlay mood label
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 10, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      key,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Vignette Overlay at bottom
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(100),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
