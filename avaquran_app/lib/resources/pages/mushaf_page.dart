import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/networking/quran_api_service.dart';
import '/config/storage_keys.dart';

class MushafPage extends NyStatefulWidget {
  static RouteView path = ("/mushaf", (_) => MushafPage());

  MushafPage({super.key}) : super(child: () => _MushafPageState());
}

class _MushafPageState extends NyPage<MushafPage> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showControls = true;
  List<dynamic> _chapters = [];
  bool _isLoadingChapters = true;

  @override
  get init => () async {
        // Load last read page from storage
        int? lastPage = await StorageKeysConfig.lastMushafPage.read();
        _currentPage = lastPage ?? 1;
        
        _pageController = PageController(initialPage: _currentPage - 1);
        await _fetchChapters();
      };

  Future<void> _fetchChapters() async {
    try {
      final response = await QuranApiService().fetchChapters();
      if (response != null && response['chapters'] != null) {
        setState(() {
          _chapters = response['chapters'];
          _isLoadingChapters = false;
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching chapters: $e");
    }
  }

  String getSurahName(int pageNumber) {
    // This is a simplified lookup. For real apps, we'd use a page-to-surah mapping.
    // For now, we'll try to extract it from the page data if available.
    return "Surat Al-Baqarah"; // Placeholder
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // THE INTERACTIVE BOOK
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: 604,
              reverse: true, // RTL swiping
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index + 1;
                });
                // Save current page to local storage
                StorageKeysConfig.lastMushafPage.save(_currentPage);
              },
              itemBuilder: (context, index) {
                return MushafSinglePage(
                  pageNumber: index + 1,
                  chapters: _chapters,
                );
              },
            ),
          ),

          // THE SWIPE INDICATORS
          if (_showControls) _buildSwipeIndicators(),

          // TOP OVERLAY (AUTO-HIDE)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            top: _showControls ? 0 : -120,
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),

          // BOTTOM OVERLAY (AUTO-HIDE)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            bottom: _showControls ? 0 : -150,
            left: 0,
            right: 0,
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(140),
            Colors.black.withAlpha(50),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            Icons.close,
            onTap: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                "Madinah Mushaf",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF267B92).withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "PAGE $_currentPage",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          _buildCircleButton(Icons.bookmark_border, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30, top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha(120),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("1", style: TextStyle(color: Colors.white54, fontSize: 10)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF267B92),
                    inactiveTrackColor: Colors.white10,
                    thumbColor: Colors.white,
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _currentPage.toDouble(),
                    min: 1,
                    max: 604,
                    onChanged: (v) {
                      setState(() {
                        _currentPage = v.toInt();
                      });
                    },
                    onChangeEnd: (v) {
                      _pageController.jumpToPage(_currentPage - 1);
                    },
                  ),
                ),
              ),
              const Text("604", style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionItem(
                Icons.menu,
                "Chapters",
                onTap: _showChaptersBottomSheet,
              ),
              _buildActionItem(Icons.auto_stories, "Mode"),
              _buildActionItem(Icons.settings_suggest, "Settings"),
              _buildActionItem(Icons.share, "Share"),
            ],
          ),
        ],
      ),
    );
  }

  void _showChaptersBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Always dark for premium feel
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Index of Surahs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withAlpha(20)),
              Expanded(
                child: _isLoadingChapters
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        itemCount: _chapters.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.white.withAlpha(10)),
                        itemBuilder: (context, index) {
                          final chapter = _chapters[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF267B92).withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "${chapter['id']}",
                                  style: const TextStyle(
                                    color: Color(0xFF267B92),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              chapter['name_simple'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "${chapter['verses_count']} Verses • ${chapter['revelation_place'].toString().capitalize()}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                            trailing: Text(
                              chapter['name_arabic'],
                              style: GoogleFonts.amiri(
                                fontSize: 20,
                                color: const Color(0xFF267B92),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              int targetPage = chapter['pages'][0];
                              _pageController.jumpToPage(targetPage - 1);
                              setState(() {
                                _currentPage = targetPage;
                              });
                              // Also save it
                              StorageKeysConfig.lastMushafPage.save(targetPage);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwipeIndicators() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Next Page Indicator (Left side for RTL)
              _buildSingleIndicator(
                icon: Icons.arrow_back_ios,
                label: "Next Page",
                isLeft: true,
              ),
              // Prev Page Indicator (Right side for RTL)
              _buildSingleIndicator(
                icon: Icons.arrow_forward_ios,
                label: "Prev Page",
                isLeft: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleIndicator({
    required IconData icon,
    required String label,
    required bool isLeft,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white.withAlpha(150), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(100),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class MushafSinglePage extends StatefulWidget {
  final int pageNumber;
  final List<dynamic> chapters;
  const MushafSinglePage({
    super.key,
    required this.pageNumber,
    required this.chapters,
  });

  @override
  State<MushafSinglePage> createState() => _MushafSinglePageState();
}

class _MushafSinglePageState extends State<MushafSinglePage> {
  bool _isLoading = true;
  Map<int, List<dynamic>>? _lines;
  String? _surahName;
  int? _juzNumber;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    try {
      final response = await QuranApiService().fetchMushafPage(
        pageNumber: widget.pageNumber,
      );
      if (response != null && response['verses'] != null) {
        Map<int, List<dynamic>> groupedLines = {};
        List<dynamic> verses = response['verses'];
        
        // Metadata extraction
        if (verses.isNotEmpty) {
          final firstVerseKey = verses[0]['verse_key'];
          final surahId = int.parse(firstVerseKey.split(':')[0]);
          final chapter = widget.chapters.firstWhere(
            (c) => c['id'] == surahId,
            orElse: () => null,
          );
          if (chapter != null) {
            _surahName = chapter['name_simple'];
          }
          _juzNumber = verses[0]['juz_number'];
        }

        for (var verse in verses) {
          for (var word in verse['words']) {
            int line = word['line_number'] ?? 0;
            groupedLines.putIfAbsent(line, () => []).add(word);
          }
        }
        if (mounted) {
          setState(() {
            _lines = groupedLines;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      NyLogger.error("Page Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRightPage = widget.pageNumber % 2 != 0;
    
    // Premium Color Palette
    final paperColor = isDark ? const Color(0xFF262626) : const Color(0xFFFDF7E9);
    final textColor = isDark ? const Color(0xFFE0D8C3) : Colors.black87;
    final accentColor = isDark ? const Color(0xFFD1B979).withAlpha(180) : const Color(0xFF8B7355);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // PAPER TEXTURE OVERLAY
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.02 : 0.04,
                child: Image.asset(
                  "assets/images/pattern_light_soft.png",
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            // MAIN CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // PAGE HEADER
                  _buildPageHeader(accentColor),
                  const SizedBox(height: 12),
                  
                  // THE QURAN LINES
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                isDark ? const Color(0xFF267B92) : const Color(0xFF267B92),
                              ),
                            ),
                          )
                        : _buildQuranLayout(textColor),
                  ),

                  // PAGE FOOTER
                  _buildPageFooter(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _surahName?.toUpperCase() ?? "...",
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: accentColor,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          "JUZ $_juzNumber".toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: accentColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPageFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        "${widget.pageNumber}",
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildQuranLayout(Color textColor) {
    if (_lines == null) return const SizedBox.shrink();
    
    List<int> sortedLineKeys = _lines!.keys.toList()..sort();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: sortedLineKeys.map((lineIndex) {
        final words = _lines![lineIndex]!;
        return Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: words.map((word) {
                final bool isEnd = word['char_type_name'] == 'end';
                return Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      word['text_uthmani'] ?? word['text'] ?? "",
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        height: 1.0,
                        color: isEnd ? const Color(0xFF267B92) : textColor,
                        fontWeight: isEnd ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
