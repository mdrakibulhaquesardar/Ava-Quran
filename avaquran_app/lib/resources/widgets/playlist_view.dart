import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/app/networking/quran_api_service.dart';
import 'package:avaquran_app/app/services/audio_player_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:avaquran_app/resources/pages/audio_player_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  // Popular Reciter IDs from Quran.com
  final List<int> _popularReciterIds = [
    7,   // Mishari Rashid al-Afasy
    3,   // Abdur-Rahman as-Sudais
    1,   // AbdulBaset AbdulSamad (Mujawwad)
    2,   // AbdulBaset AbdulSamad (Murattal)
    14,  // Maher al-Muaiqly
    124, // Yasser Al-Dosari
    54,  // Abdul Rahman Al-Ossi
    13,  // Saad el Ghamidi
    10,  // Saud al-Shuraim
    4,   // Abu Bakr al-Shatri
    5,   // Hani ar-Rifai
    6,   // Mahmoud Khalil Al-Husary
    11,  // Mohamed Siddiq al-Minshawi
    8,   // Ali Jaber
  ];

  // Actual photo links for reciters (using dummy links for now as requested)
  final Map<String, String> _reciterImages = {
    '7': 'https://i.pinimg.com/originals/71/b3/bd/71b3bd96477aa44881347e535d5b96b0.jpg',
    '3': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRulzZjeBWvVCGk89Q9Jg80abPJXadD-5DQJA&s',
    '1': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRXd_-HzID0JSuI6YA9hjTqFiEgX3nXTtfZAg&s',
    '2': 'https://cdn-images.dzcdn.net/images/artist/60434789da4b07a272081341bea95aa0/1900x1900-000000-81-0-0.jpg',
    '14': 'https://www.assabile.com/media/person/280x219/maher-al-mueaqly.png',
    '124': 'https://i.scdn.co/image/ab6761610000e5eb6a6628f0fcfd0b1b01bbf912',
    '54': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4-oGQ2_wpL7-UasaML7IriNXTfxQiH-6YXg&s',
    '13': 'https://upload.wikimedia.org/wikipedia/commons/4/43/Saad_al_Ghamdi.jpg',
    '10': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4-oGQ2_wpL7-UasaML7IriNXTfxQiH-6YXg&s',
    '4': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwRzDdZ-Hh4146qXYoczHjawIGCMJSEMbnzQ&s',
    '5': 'https://api2.quran-pro.com/images/hani-ar-rifai/hani-ar-rifai-medium.webp?version=1686737997907',
    '6': 'https://elhosary.co/wp-content/uploads/2023/01/%D8%A7%D9%84%D8%B4%D9%8A%D8%AE-%D9%85%D8%AD%D9%85%D9%88%D8%AF-%D8%AE%D9%84%D9%8A%D9%84-%D8%A7%D9%84%D8%AD%D8%B5%D8%B1%D9%8A.jpg',
    '11': 'https://i.scdn.co/image/ab67616d0000b273066a714dbb5c25660403f700',
    '8': 'https://upload.wikimedia.org/wikipedia/commons/7/7c/%D8%A7%D9%84%D8%B4%D9%8A%D8%AE_%D8%B9%D9%84%D9%8A_%D8%AC%D8%A7%D8%A8%D8%B1.png',
  };

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
      
      List<dynamic> allReciters = recitersData['recitations'] ?? [];
      
      // Filter for popular reciters and sort them according to our popular list
      List<dynamic> popularReciters = [];
      for (int id in _popularReciterIds) {
        final reciter = allReciters.firstWhere((r) => r['id'] == id, orElse: () => null);
        if (reciter != null) {
          popularReciters.add(reciter);
        }
      }
      
      setState(() {
        _reciters = popularReciters.isNotEmpty ? popularReciters : allReciters.take(15).toList();
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
                            color: isSelected ? const Color(0xFF267B92) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF267B92) : Colors.grey.shade200,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                  ? const Color(0xFF267B92).withAlpha(60) 
                                  : Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _reciterImages[reciter['id'].toString()] ?? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(reciter['reciter_name'])}&background=${isSelected ? '267B92' : 'f3f4f6'}&color=${isSelected ? 'ffffff' : '9ca3af'}&bold=true&font-size=0.35",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => CachedNetworkImage(
                                imageUrl: "https://ui-avatars.com/api/?name=${Uri.encodeComponent(reciter['reciter_name'])}&background=${isSelected ? '267B92' : 'f3f4f6'}&color=${isSelected ? 'ffffff' : '9ca3af'}&bold=true&font-size=0.35",
                                fit: BoxFit.cover,
                              ),
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
