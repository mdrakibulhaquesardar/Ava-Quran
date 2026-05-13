import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/api_service.dart';

class CreateBlogPage extends NyStatefulWidget {
  static RouteView path = ("/create-blog", (_) => CreateBlogPage());

  CreateBlogPage({super.key}) : super(child: () => _CreateBlogPageState());
}

class _CreateBlogPageState extends NyPage<CreateBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  final Color _brandAccent = const Color(0xFF267B92);
  bool _isPublishing = false;

  @override
  get init => () {};

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publishBlog() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty) {
      showToastWarning(description: "Please provide a title for your reflection.");
      return;
    }

    if (content.isEmpty) {
      showToastWarning(description: "The story cannot be empty. Type something from the heart!");
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final response = await ApiService().createBlog(title: title, content: content);
      if (response != null && mounted) {
        showToastSuccess(description: "Successfully published to the community! 🎉");
        // Pop with true to notify parent list to refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      NyLogger.error("Error creating blog: $e");
      if (mounted) {
        showToastDanger(description: "Failed to publish blog. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leadingWidth: 80,
        centerTitle: true,
        title: const Text(
          "Draft",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 10.0, bottom: 10.0),
            child: _isPublishing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _publishBlog,
                    style: TextButton.styleFrom(
                      backgroundColor: _brandAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Publish",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Title TextField
              TextField(
                controller: _titleController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  hintText: "Title your reflection...",
                  hintStyle: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade300,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              
              const SizedBox(height: 8),
              Divider(color: Colors.grey.shade100, thickness: 1.5),
              const SizedBox(height: 8),
              
              // Content Area
              TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                autofocus: false,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: "What is on your mind today? Share your Quran insights, life stories, or spiritual reminders...",
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
