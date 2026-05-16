import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/resources/widgets/trend_video_card_widget.dart';
import 'package:avaquran_app/resources/pages/video_feed_page.dart';
import 'package:avaquran_app/app/networking/api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class VideosView extends StatefulWidget {
  const VideosView({super.key});

  @override
  State<VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosView> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _videos = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      if (!_isLoading && !_isFetchingMore && _hasMore) {
        _fetchMoreVideos();
      }
    }
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _page = 1;
    });
    try {
      final response = await ApiService().fetchMostLoved(page: _page, limit: 15);
      if (response != null && response['data'] != null) {
        setState(() {
          _videos = List.from(response['data']);
          _hasMore = _videos.length >= 15;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching videos: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreVideos() async {
    setState(() {
      _isFetchingMore = true;
    });
    try {
      final nextPage = _page + 1;
      final response = await ApiService().fetchMostLoved(page: nextPage, limit: 15);
      if (response != null && response['data'] != null) {
        final newVideos = response['data'] as List;
        setState(() {
          _page = nextPage;
          _videos.addAll(newVideos);
          _hasMore = newVideos.length >= 15;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching more videos: $e");
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  String _formatCounter(dynamic count) {
    if (count == null) return "0";
    final int numCount = count is int ? count : int.tryParse(count.toString()) ?? 0;
    if (numCount >= 1000000) return "${(numCount / 1000000).toStringAsFixed(1)}M";
    if (numCount >= 1000) return "${(numCount / 1000).toStringAsFixed(1)}K";
    return numCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _isLoading
              ? _buildShimmerGrid()
              : RefreshIndicator(
                  onRefresh: _fetchVideos,
                  child: MasonryGridView.count(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemCount: _videos.length + (_isFetchingMore ? 3 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _videos.length) {
                        return _buildShimmerItem(index);
                      }
                      final video = _videos[index];
                      final background = video["videoBackground"];
                      final meta = video["videoMeta"];

                      // Pattern: Items at 2, 10, 18 (i % 18 == 2) are tall on right
                      // Items at 11, 29, 47 (i % 18 == 11) are tall on left
                      // This mimics the Instagram Explore style staggered grid
                      final bool isTall = (index % 18 == 2) || (index % 18 == 11);

                      return GestureDetector(
                        onTap: () {
                          routeTo(
                            VideoFeedPage.path,
                            data: {
                              'initialVerseKey': video["verseKey"],
                              'preloadedFeed': _videos,
                              'feedType': 'most_loved',
                            },
                          );
                        },
                        child: Container(
                          height: isTall ? 300 : 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  background?["url"] ?? "",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.video_library)),
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Row(
                                  children: [
                                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      _formatCounter(meta?["likes"]),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: 15,
      itemBuilder: (context, index) => _buildShimmerItem(index),
    );
  }

  Widget _buildShimmerItem(int index) {
    final bool isTall = (index % 18 == 2) || (index % 18 == 11);
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: isTall ? 300 : 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
