import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/blog_card_widget.dart';

class BlogsPage extends NyStatefulWidget {
  static RouteView path = ("/blogs", (_) => BlogsPage());

  BlogsPage({super.key}) : super(child: () => _BlogsPageState());
}

class _BlogsPageState extends NyPage<BlogsPage> {
  final Color _brandAccent = const Color(0xFF267B92);
  int _selectedCategoryIndex = 0;

  final List<String> _categories = ["All", "Reflection", "Lifestyle", "Learning", "History", "Kids"];

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

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA), // Premium off-white
      body: Column(
        children: [
          // 1. SEARCH / HEADER (TOP BAR)
          _buildHeader(),

          // 2. CATEGORIES SELECTOR
          _buildCategories(),

          // 3. MAIN CONTENT LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 10),
                // HERO FEATURED POST
                _buildHeroPost(),
                
                const SizedBox(height: 30),
                
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
                const SizedBox(height: 10),

                // LIST OF REMAINING BLOGS
                ..._blogs.map((blog) => BlogCard(
                      title: blog["title"]!,
                      author: blog["author"]!,
                      date: blog["date"]!,
                      image: blog["image"]!,
                      category: blog["category"]!,
                    )).toList(),

                const SizedBox(height: 30), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 16),
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
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
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
                _categories[index],
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
    );
  }

  Widget _buildHeroPost() {
    return Container(
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
            // Background Hero Image
            Image.asset(
              "assets/images/blog_sample_1.png",
              fit: BoxFit.cover,
            ),
            // Dark Gradient Overlay
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
            // Content Overlay
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
                      Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 22),
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
