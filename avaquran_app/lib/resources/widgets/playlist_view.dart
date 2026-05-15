import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/app/networking/quran_api_service.dart';
import 'package:avaquran_app/app/services/audio_player_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:avaquran_app/resources/pages/audio_player_page.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final QuranApiService _apiService = QuranApiService();
  final QuranAudioPlayerService _audioService = QuranAudioPlayerService();
  
  List<dynamic> _reciters = [];
  List<dynamic> _chapters = [];
  bool _isLoading = true;
  int _selectedReciterId = 7; // Default: Mishary Rashid Alafasy

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recitersData = await _apiService.fetchRecitations();
      final chaptersData = await _apiService.fetchChapters();
      
      setState(() {
        _reciters = recitersData['recitations'] ?? [];
        _chapters = chaptersData['chapters'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      NyLogger.error("Error loading playlist data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildRecitersSection(),
          _buildChaptersSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quran Playlists",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Listen to your favorite reciters and surahs.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecitersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Popular Reciters",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _reciters.length,
            itemBuilder: (context, index) {
              final reciter = _reciters[index];
              final isSelected = reciter['id'] == _selectedReciterId;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedReciterId = reciter['id']),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFF267B92) : Colors.grey.shade100,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF267B92) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: const Color(0xFF267B92).withAlpha(40),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reciter['reciter_name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF267B92) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChaptersSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Surah List",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _chapters.length,
            itemBuilder: (context, index) {
              final chapter = _chapters[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF267B92).withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "${chapter['id']}",
                        style: const TextStyle(
                          color: Color(0xFF267B92),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    chapter['name_simple'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "${chapter['verses_count']} Verses",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chapter['name_arabic'],
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: Color(0xFF267B92),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF267B92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    _audioService.setPlaylist(_chapters, reciterId: _selectedReciterId);
                    await _audioService.playSurah(
                      chapter,
                      reciterId: _selectedReciterId,
                    );
                    routeTo(AudioPlayerPage.path, data: chapter);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPlayerMiniControl(dynamic chapter) {
     // TODO: Implement mini player overlay or persistent bottom bar
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
