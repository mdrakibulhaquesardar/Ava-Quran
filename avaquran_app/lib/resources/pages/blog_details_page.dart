import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../app/networking/api_service.dart';

class BlogDetailsPage extends NyStatefulWidget {
  static RouteView path = ("/blog-details", (_) => BlogDetailsPage());

  BlogDetailsPage({super.key}) : super(child: () => _BlogDetailsPageState());
}

class _BlogDetailsPageState extends NyPage<BlogDetailsPage> {
  dynamic _blogData;
  bool _isLoadingFullBody = true;

  @override
  get init => () {
    _blogData = widget.controller.data();
    if (_blogData != null && _blogData["id"] != null) {
      // Optimistically load what we have, then fetch complete content body
      _fetchFullBlogContent(_blogData["id"].toString());
    } else {
      _isLoadingFullBody = false;
    }
  };

  Future<void> _fetchFullBlogContent(String blogId) async {
    try {
      final detail = await ApiService().fetchBlogDetails(blogId: blogId);
      if (detail != null && mounted) {
        setState(() {
          _blogData = detail;
          _isLoadingFullBody = false;
        });
      }
    } catch (e) {
      NyLogger.error("Failed loading blog detail body: $e");
      if (mounted) {
        setState(() {
          _isLoadingFullBody = false;
        });
      }
    }
  }

  String _formatBlogDate(String? dateStr) {
    if (dateStr == null) return "Recently";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, y').format(date);
    } catch (e) {
      return "Recently";
    }
  }

  @override
  Widget view(BuildContext context) {
    if (_blogData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String id = _blogData["id"]?.toString() ?? UniqueKey().toString();
    final String title = _blogData["title"] ?? "Spiritual Reflection";
    final String author = _blogData["user"]?["name"] ?? _blogData["author"] ?? "Community Member";
    final String date = _formatBlogDate(_blogData["createdAt"]);
    final String? thumbUrl = _blogData["thumbnailUrl"];
    final String content = _blogData["content"] ?? _blogData["contentPreview"] ?? "";
    final int readTime = _blogData["readTime"] ?? 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. IMMERSIVE HERO APPBAR
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(80),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero transitions bounded from parent lists
                  Hero(
                    tag: "blog-image-$id",
                    child: (thumbUrl != null && thumbUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: thumbUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFEBF5F7),
                              child: const Icon(Icons.article_outlined, color: Color(0xFF267B92), size: 64),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFEBF5F7),
                            child: const Icon(Icons.article_outlined, color: Color(0xFF267B92), size: 64),
                          ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                          ],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CONTENT BODY
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CATEGORY TAG
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF267B92).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$readTime MIN READ",
                        style: const TextStyle(
                          color: Color(0xFF267B92),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MAIN TITLE
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // AUTHOR & DATE METADATA
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFEBF5F7),
                          child: Icon(Icons.person, color: Color(0xFF267B92)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF267B92).withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_add_outlined,
                            color: Color(0xFF267B92),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(thickness: 1.2, color: Color(0xFFEEEEEE)),
                    ),

                    // MAIN ARTICLE CONTENT WITH SOFT LOADER SPINNER IF STILL DOWNLOADING THE FULL BODY
                    _isLoadingFullBody
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          )
                        : Text(
                            content,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF333333),
                              height: 1.7,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                    
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
