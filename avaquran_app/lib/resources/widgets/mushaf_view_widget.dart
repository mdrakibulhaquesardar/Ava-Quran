import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/quran_api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MushafViewWidget extends StatefulWidget {
  const MushafViewWidget({super.key});

  @override
  State<MushafViewWidget> createState() => _MushafViewWidgetState();
}

class _MushafViewWidgetState extends State<MushafViewWidget> {
  int _currentPage = 1;
  bool _isLoading = true;
  dynamic _pageData;
  final QuranApiService _apiService = QuranApiService();

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  Future<void> _loadPage(int page) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.fetchMushafPage(pageNumber: page);
      if (response != null && response['verses'] != null) {
        if (mounted) {
          // Flatten all words from all verses on this page
          List<dynamic> allWords = [];
          for (var verse in response['verses']) {
            if (verse['words'] != null) {
              allWords.addAll(verse['words']);
            }
          }
          setState(() {
            _pageData = allWords;
            _currentPage = page;
          });
        }
      }
    } catch (e) {
      NyLogger.error("Error loading Mushaf page: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 604) {
      _loadPage(_currentPage + 1);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      _loadPage(_currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB)),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Image.asset(
              "assets/images/pattern_light_soft.png",
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.05),
            ),
          ),

          Column(
            children: [
              // Header Info
              _buildHeader(),

              // Page Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF267B92),
                          ),
                        ),
                      )
                    : _buildMushafPage(),
              ),

              // Navigation Controls
              _buildControls(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Page $_currentPage",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "Uthmani Script",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF267B92).withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Madinah Mushaf",
              style: TextStyle(
                color: Color(0xFF267B92),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushafPage() {
    if (_pageData == null || (_pageData as List).isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No content available for this page.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final List<dynamic> words = _pageData;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            runSpacing: 8,
            children: words.map((word) {
              final String text = word['text_uthmani'] ?? word['text'] ?? "";
              final bool isEnd = word['char_type_name'] == 'end';

              return Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 24,
                  height: 1.8,
                  color: isEnd ? const Color(0xFF267B92) : Colors.black87,
                  fontWeight: isEnd ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.arrow_back_ios_new,
            label: "Prev",
            onTap: _prevPage,
            enabled: _currentPage > 1,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              "$_currentPage / 604",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          _buildNavButton(
            icon: Icons.arrow_forward_ios,
            label: "Next",
            onTap: _nextPage,
            enabled: _currentPage < 604,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF267B92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF267B92).withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (label == "Prev") Icon(icon, color: Colors.white, size: 14),
              if (label == "Prev") const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (label == "Next") const SizedBox(width: 8),
              if (label == "Next") Icon(icon, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
