import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/resources/pages/blog_details_page.dart';
import 'package:intl/intl.dart';

class BlogCard extends StatefulWidget {
  final dynamic blog;
  final String heroPrefix;

  const BlogCard({
    super.key,
    required this.blog,
    this.heroPrefix = 'blog-list',
  });

  @override
  createState() => _BlogCardState();
}

class _BlogCardState extends NyState<BlogCard> {
  @override
  get init => () {};

  String _formatBlogDate(String? dateStr) {
    if (dateStr == null) return "Recently";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return "Recently";
    }
  }

  @override
  Widget view(BuildContext context) {
    final dynamic blog = widget.blog;
    final String id = blog["id"]?.toString() ?? UniqueKey().toString();
    final String title = blog["title"] ?? "Spiritual Reflection";
    final String author = blog["user"]?["name"] ?? blog["author"] ?? "Community Member";
    final String date = _formatBlogDate(blog["createdAt"]);
    final String? thumbUrl = blog["thumbnailUrl"];
    final int readTime = blog["readTime"] ?? 1;
    
    return GestureDetector(
      onTap: () => routeTo(BlogDetailsPage.path, data: blog),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // 1. HERO IMAGE THUMBNAIL
            Hero(
              tag: "${widget.heroPrefix}-image-$id",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 85,
                  height: 85,
                  color: Colors.grey.shade100,
                  child: (thumbUrl != null && thumbUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: thumbUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFEBF5F7),
                            child: const Icon(Icons.article_outlined, color: Color(0xFF267B92)),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFEBF5F7),
                          child: const Icon(Icons.article_outlined, color: Color(0xFF267B92)),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2. CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading time tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF267B92).withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "$readTime MIN READ",
                      style: const TextStyle(
                        color: Color(0xFF267B92),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Footer info
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "• $author",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
