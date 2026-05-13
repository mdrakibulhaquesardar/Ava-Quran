import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/networking/api_service.dart';
import '/resources/pages/collection_details_page.dart';

class CollectionsPage extends NyStatefulWidget {
  static RouteView path = ("/collections", (_) => CollectionsPage());

  CollectionsPage({super.key}) : super(child: () => _CollectionsPageState());
}

class _CollectionsPageState extends NyPage<CollectionsPage> {
  final Color _brandAccent = const Color(0xFF267B92); // Matching Deep Teal app branding
  
  List<dynamic> _collections = [];
  bool _isLoading = true;

  @override
  get init => () {
    _loadCollections();
  };

  Future<void> _loadCollections() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await ApiService().fetchCollections();
      if (res != null && mounted) {
        setState(() {
          _collections = List.from(res);
        });
      }
    } catch (e) {
      NyLogger.error("Failed to load collections: $e");
      showToastDanger(description: "Unable to load collections. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateCollectionDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: const Text(
          "New Collection",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "e.g., Peaceful Reminders",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _brandAccent, width: 2),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () async {
              final String val = nameController.text.trim();
              if (val.isEmpty) return;
              Navigator.pop(ctx);
              await _createCollection(val);
            },
            child: const Text("Create", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _createCollection(String name) async {
    try {
      final newCol = await ApiService().createCollection(title: name);
      if (newCol != null && mounted) {
        showToastSuccess(description: "'$name' successfully added!");
        // Refresh list to grab updated assets
        _loadCollections();
      }
    } catch (e) {
      showToastDanger(description: "Failed to create collection. Make sure title is valid.");
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA), // Matches overall app background
      body: Stack(
        children: [
          // Elegant background pattern
          Positioned.fill(
            child: Image.asset(
              "assets/images/pattern_light_soft.png",
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.04),
            ),
          ),

          // Main Content
          RefreshIndicator(
            color: _brandAccent,
            onRefresh: _loadCollections,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // Premium Floating-look AppBar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFFF8FBFA).withAlpha(240),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: const Text(
                    "Collections",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline_rounded, color: _brandAccent, size: 26),
                      onPressed: _showCreateCollectionDialog,
                    ),
                  ],
                ),

                if (_isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_brandAccent),
                      ),
                    ),
                  )
                else if (_collections.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _brandAccent.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.bookmark_outline_rounded, color: _brandAccent, size: 60),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "No Collections Yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Save favorite reels and organize your\nspiritual reminders.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _showCreateCollectionDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Create First Collection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _collections[index];
                          return _buildCollectionCard(item);
                        },
                        childCount: _collections.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _collections.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: _brandAccent,
              elevation: 4,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("New Folder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _showCreateCollectionDialog,
            )
          : null,
    );
  }

  Widget _buildCollectionCard(dynamic item) {
    final String title = item['title'] ?? 'Untitled';
    final int count = item['savedCount'] ?? 0;
    final String? thumb = item['thumbnailUrl'];

    return GestureDetector(
      onTap: () {
        // Route to CollectionDetailsPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetailsPage(
              collectionId: item['id'].toString(),
              collectionTitle: title,
            ),
          ),
        ).then((value) {
          // Refresh count/thumbnails on return
          _loadCollections();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _brandAccent.withAlpha(12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Full Bleed Image Cover with soft gradient
            Positioned.fill(
              child: thumb != null
                  ? CachedNetworkImage(
                      imageUrl: thumb,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Container(color: Colors.grey.shade200),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                    ),
            ),

            // Elegant dark overlay gradient on the bottom half
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(0),
                              Colors.black.withAlpha(60),
                              Colors.black.withAlpha(180),
                            ],
                            stops: const [0.4, 0.7, 1.0],
                          ),
                ),
              ),
            ),

            // Floating overlay content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$count saved",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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
}
