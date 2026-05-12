import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BlogDetailsPage extends NyStatefulWidget {
  static RouteView path = ("/blog-details", (_) => BlogDetailsPage());

  BlogDetailsPage({super.key}) : super(child: () => _BlogDetailsPageState());
}

class _BlogDetailsPageState extends NyPage<BlogDetailsPage> {
  String? title;
  String? author;
  String? image;
  String? date;
  String? category;

  @override
  get init => () {
        // Pull parameters from route arguments if available
        final args = widget.controller.data();
        if (args != null && args is Map) {
          title = args['title'];
          author = args['author'];
          image = args['image'];
          date = args['date'];
          category = args['category'];
        }
        // Fallbacks for safety
        title ??= "Cultivating a Life of Gratitude Through Divine Teachings";
        author ??= "Ustadh Ali";
        image ??= "assets/images/blog_sample_1.png";
        date ??= "Oct 12";
        category ??= "Reflection";
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // IMMERSIVE IMAGE HEADER
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
                  Image.asset(
                    image!,
                    fit: BoxFit.cover,
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black45,
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

          // BLOG CONTENT
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
                        category!.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF267B92),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MAIN TITLE
                    Text(
                      title!,
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
                          backgroundColor: Color(0xFFF0F4F8),
                          child: Icon(Icons.person, color: Colors.blueGrey),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$date • 5 min read",
                              style: TextStyle(
                                fontSize: 13,
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
                      child: Divider(),
                    ),

                    // ARTICLE BODY TEXT
                    const Text(
                      "In our fast-paced modern world, finding tranquility can often feel like an elusive goal. The daily noise of technology, societal demands, and individual challenges can create a veil of continuous distraction. Yet, the ultimate remedy for our inner turbulence resides in one profound practice: Shukr (Gratitude).",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // BLOCK QUOTE
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFA),
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF267B92), width: 4),
                        ),
                      ),
                      child: const Text(
                        "\"And [remember] when your Lord proclaimed, 'If you are grateful, I will surely increase you [in favor].'\" — Surah Ibrahim, 14:7",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      "Developing this deep connection necessitates intentional, daily actions. Start by carving out silent moments each morning—away from devices—to meditate on the countless gifts we inherit without asking. Reflection allows the heart to breathe, recalibrating our focus on what truly matters.",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Prophetic traditions encourage us to view every trial as an opportunity for refinement and every blessing as a catalyst for charity. By transforming our mindset through these divine teachings, we create an internal sanctuary that remains steady regardless of the external storms brewing around us.",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
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
