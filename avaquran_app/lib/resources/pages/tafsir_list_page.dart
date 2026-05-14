import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/quran_api_service.dart';
import 'tafsir_details_page.dart';

class TafsirListPage extends NyStatefulWidget {
  static RouteView path = ("/tafsir-list", (_) => TafsirListPage());
  
  TafsirListPage({super.key}) : super(child: () => _TafsirListPageState());
}

class _TafsirListPageState extends NyPage<TafsirListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allSurahs = [];
  List<Map<String, dynamic>> _filteredSurahs = [];
  bool _isLoading = true;

  @override
  get init => () async {
    await _loadSurahList();
  };

  Future<void> _loadSurahList() async {
    // Standard list of 114 Surahs
    // In a real app, you might fetch this from an API, 
    // but 114 names are static and better preloaded for speed.
    final List<String> surahNames = [
      "Al-Fatihah", "Al-Baqarah", "Ali 'Imran", "An-Nisa'", "Al-Ma'idah", "Al-An'am",
      "Al-A'raf", "Al-Anfal", "At-Tawbah", "Yunus", "Hud", "Yusuf", "Ar-Ra'd", "Ibrahim",
      "Al-Hijr", "An-Nahl", "Al-Isra'", "Al-Kahf", "Maryam", "Ta-Ha", "Al-Anbiya'",
      "Al-Hajj", "Al-Mu'minun", "An-Nur", "Al-Furqan", "Ash-Shu'ara'", "An-Naml",
      "Al-Qasas", "Al-Ankabut", "Ar-Rum", "Luqman", "As-Sajdah", "Al-Ahzab", "Saba'",
      "Fatir", "Ya-Sin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir", "Fussilat", "Ash-Shura",
      "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiyah", "Al-Ahqaf", "Muhammad", "Al-Fath",
      "Al-Hujurat", "Qaf", "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman",
      "Al-Waqi'ah", "Al-Hadid", "Al-Mujadilah", "Al-Hashr", "Al-Mumtahanah", "As-Saff",
      "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq", "At-Tahrim", "Al-Mulk",
      "Al-Qalam", "Al-Haqqah", "Al-Ma'arij", "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddatthir",
      "Al-Qiyamah", "Al-Insan", "Al-Mursalat", "An-Naba'", "An-Nazi'at", "'Abasa",
      "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj", "At-Tariq",
      "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad", "Ash-Shams", "Al-Layl", "Ad-Duha",
      "Ash-Sharh", "At-Tin", "Al-'Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah",
      "Al-'Adiyat", "Al-Qari'ah", "At-Takathur", "Al-'Asr", "Al-Humazah", "Al-Fil",
      "Quraysh", "Al-Ma'un", "Al-Kawthar", "Al-Kafirun", "An-Nasr", "Al-Masad", "Al-Ikhlas",
      "Al-Falaq", "An-Nas"
    ];

    final List<String> arabicNames = [
      "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال",
      "التوبة", "يونس", "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء",
      "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء",
      "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب", "سبأ", "فاطر",
      "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية",
      "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات", "الطور", "النجم", "القمر",
      "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة", "الصف", "الجمعة",
      "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم", "الحاقة", "المعارج",
      "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات",
      "عبس", "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى",
      "الغاشية", "الفجر", "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق",
      "القدر", "البينة", "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة",
      "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق",
      "الناس"
    ];

    _allSurahs = List.generate(114, (index) {
      return {
        "number": index + 1,
        "name": surahNames[index],
        "arabic": arabicNames[index],
      };
    });

    setState(() {
      _filteredSurahs = _allSurahs;
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filteredSurahs = _allSurahs.where((surah) {
        final name = surah['name'].toLowerCase();
        final arabic = surah['arabic'];
        final number = surah['number'].toString();
        return name.contains(query.toLowerCase()) || 
               arabic.contains(query) || 
               number == query;
      }).toList();
    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Surah Tafsirs",
          style: TextStyle(
            color: context.isThemeDark ? Colors.white : const Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.isThemeDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: context.isThemeDark ? const Color(0xFF0A232F) : const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: context.isThemeDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: TextStyle(color: context.isThemeDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Search Surah by name or number...",
                  hintStyle: TextStyle(color: context.isThemeDark ? Colors.white54 : Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF267B92)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          
          // Surah List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF267B92)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return _buildSurahCard(surah);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            routeTo(TafsirDetailsPage.path, data: surah);
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isThemeDark ? const Color(0xFF0A232F) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: context.isThemeDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8EEF2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Surah Number with Islamic Border
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF267B92).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      surah['number'].toString(),
                      style: const TextStyle(
                        color: Color(0xFF267B92),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                
                // Surah Names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah['name'],
                        style: TextStyle(
                          color: context.isThemeDark ? Colors.white : const Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Chapter ${surah['number']}",
                        style: TextStyle(
                          color: context.isThemeDark ? Colors.white54 : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arabic Name
                Text(
                  surah['arabic'],
                  style: const TextStyle(
                    color: Color(0xFF267B92),
                    fontSize: 20,
                    fontFamily: 'Amiri', // Use a nice Arabic font if available
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: context.isThemeDark ? Colors.white24 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
