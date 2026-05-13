import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/networking/api_service.dart';
import '/resources/widgets/blog_card_widget.dart';
import '/resources/pages/blog_details_page.dart';
import '/resources/pages/create_blog_page.dart';

class BlogsPage extends NyStatefulWidget {
  static RouteView path = ("/blogs", (_) => BlogsPage());

  BlogsPage({super.key}) : super(child: () => _BlogsPageState());
}

class _BlogsPageState extends NyPage<BlogsPage> {
  final Color _brandAccent = const Color(0xFF267B92);

  late ScrollController _blogsScrollController;
  List<dynamic> _blogItems = [];
  bool _isLoadingBlogs = true;
  bool _isFetchingMoreBlogs = false;
  int _blogsPage = 1;
  bool _blogsHasMore = true;

  @override
  get init => () {
    _blogsScrollController = ScrollController()..addListener(_onBlogsScroll);
    _fetchBlogsData();
  };

  @override
  void dispose() {
    _blogsScrollController.dispose();
    super.dispose();
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
      NyLogger.error("Error loading standalone blogs: $e");
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
      NyLogger.error("Error fetching more standalone blogs: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMoreBlogs = false;
        });
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Community Blogs",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF267B92)),
            onPressed: () async {
              final published = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateBlogPage()),
              );
              if (published == true) {
                _fetchBlogsData();
              }
            },
          ),
        ],
      ),
      body: _isLoadingBlogs
          ? ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 6,
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
            )
          : _blogItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: _brandAccent.withAlpha(60)),
                      const SizedBox(height: 16),
                      Text(
                        "No articles published yet.",
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
                        label: const Text("Try Again"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBlogsData,
                  child: ListView.builder(
                    controller: _blogsScrollController,
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _blogItems.length + (_isFetchingMoreBlogs ? 1 : 0),
                    itemBuilder: (context, index) {
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

                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroPost(blog),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Recent Articles",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }

                      return BlogCard(blog: blog);
                    },
                  ),
                ),
    );
  }

  Widget _buildHeroPost(dynamic blog) {
    final String id = blog["id"]?.toString() ?? UniqueKey().toString();
    final String title = blog["title"] ?? "";
    final String author = blog["user"]?["name"] ?? "Ava Writer";
    final String? thumbUrl = blog["thumbnailUrl"];

    return GestureDetector(
      onTap: () => routeTo(BlogDetailsPage.path, data: blog),
      child: Container(
        width: double.infinity,
        height: 240,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                        ],
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
                        const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 22),
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
