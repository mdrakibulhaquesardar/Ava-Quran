import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_html/flutter_html.dart';
import '/app/networking/quran_api_service.dart';

class TafsirDetailsPage extends NyStatefulWidget {
  static RouteView path = ("/tafsir-details", (_) => TafsirDetailsPage());
  
  TafsirDetailsPage({super.key}) : super(child: () => _TafsirDetailsPageState());
}

class _TafsirDetailsPageState extends NyPage<TafsirDetailsPage> {
  Map<String, dynamic>? _surah;
  List<dynamic> _tafsirItems = [];
  List<dynamic> _resources = [];
  int? _selectedResourceId;
  bool _isLoading = true;
  bool _isLoadingTafsir = false;

  @override
  get init => () async {
    _surah = widget.data();
    await _loadResources();
    if (_resources.isNotEmpty) {
      // Default to a Bengali tafsir: 
      // 166 (Abu Bakr Zakaria) is generally preferred, 
      // followed by 164 (Ibn Kathir).
      final preferred = _resources.firstWhere(
        (r) => r['id'] == 166 || r['id'] == 164 || r['language_name'] == 'bengali',
        orElse: () => _resources.firstWhere(
          (r) => r['language_name'] == 'english', 
          orElse: () => _resources.first,
        ),
      );
      _selectedResourceId = preferred['id'];
      await _fetchTafsir();
    }
  };

  Future<void> _loadResources() async {
    try {
      final response = await QuranApiService().fetchTafsirResources();
      if (response != null && response['tafsirs'] != null) {
        setState(() {
          _resources = response['tafsirs'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      NyLogger.error("Error loading tafsir resources: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTafsir() async {
    if (_selectedResourceId == null || _surah == null) return;
    
    setState(() => _isLoadingTafsir = true);
    try {
      final response = await QuranApiService().fetchTafsirByChapter(
        resourceId: _selectedResourceId!,
        chapterNumber: _surah!['number'],
      );
      
      if (response != null && response['tafsirs'] != null) {
        setState(() {
          // Filter out items with empty text to avoid showing blank items in the UI
          _tafsirItems = (response['tafsirs'] as List).where((item) {
            String? text = item['text'];
            return text != null && text.trim().isNotEmpty;
          }).toList();
        });
      } else {
        setState(() {
          _tafsirItems = [];
        });
      }
    } catch (e) {
      NyLogger.error("Error fetching tafsir: $e");
      showToastWarning(description: "Could not load tafsir content.");
      setState(() {
        _tafsirItems = [];
      });
    } finally {
      setState(() => _isLoadingTafsir = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              _surah?['name'] ?? "Surah Tafsir",
              style: TextStyle(
                color: context.isThemeDark ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_surah != null)
              Text(
                "Chapter ${_surah!['number']} • ${_surah!['arabic']}",
                style: TextStyle(
                  color: context.isThemeDark ? Colors.white54 : Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.isThemeDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: context.isThemeDark ? Colors.white70 : Colors.black54),
            onPressed: _showTafsirPicker,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF267B92)))
        : _isLoadingTafsir
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF267B92)))
          : _tafsirItems.isEmpty
            ? const Center(child: Text("No tafsir content found."))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _tafsirItems.length,
                itemBuilder: (context, index) {
                  final item = _tafsirItems[index];
                  return _buildTafsirItem(item);
                },
              ),
    );
  }

  Widget _buildTafsirItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isThemeDark ? const Color(0xFF0A232F) : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isThemeDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8EEF2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayah Reference
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF267B92).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Verse ${item['verse_key'] ?? item['verse_number']}",
                      style: const TextStyle(
                        color: Color(0xFF267B92),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 12,
                      width: 1,
                      color: const Color(0xFF267B92).withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showWordAnalysis(item['verse_key'] ?? item['verse_number'].toString()),
                      child: const Text(
                        "Word Analysis",
                        style: TextStyle(
                          color: Color(0xFF267B92),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.bookmark_outline, size: 20, color: context.isThemeDark ? Colors.white24 : Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tafsir Text (HTML)
          Html(
            data: item['text'] ?? "",
            style: {
              "body": Style(
                color: context.isThemeDark ? Colors.white.withOpacity(0.9) : const Color(0xFF2D3133),
                fontSize: FontSize(15),
                lineHeight: LineHeight.number(1.6),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "a": Style(
                color: const Color(0xFF267B92),
                textDecoration: TextDecoration.none,
              ),
            },
          ),
        ],
      ),
    );
  }

  void _showWordAnalysis(String ayahKey) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<dynamic>(
              future: QuranApiService().fetchWordMorphology(ayahKey: ayahKey),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF267B92)));
                }
                
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text("Could not load word analysis."));
                }

                final words = snapshot.data['verse']['words'] as List;
                
                return Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.translate, color: Color(0xFF267B92), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Word Analysis - $ayahKey",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: context.isThemeDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          final word = words[index];
                          if (word['text_uthmani'] == null) return const SizedBox.shrink();
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: context.isThemeDark ? const Color(0xFF0A232F) : const Color(0xFFF8FAFB),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: context.isThemeDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8EEF2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      word['text_uthmani'] ?? "",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Amiri', // Assuming you have a Quran font or use default
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF267B92),
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    Text(
                                      word['translation'] is Map ? (word['translation']['text'] ?? "") : (word['translation'] ?? ""),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context.isThemeDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                if (word['root'] != null)
                                  _buildInfoRow("Root", word['root'], context),
                                if (word['lemma'] != null)
                                  _buildInfoRow("Lemma", word['lemma'], context),
                                if (word['grammatical_features'] != null && word['grammatical_features']['part_of_speech'] != null)
                                  _buildInfoRow("Part of Speech", word['grammatical_features']['part_of_speech'].toString().capitalize(), context),
                                if (word['description'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      word['description'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.isThemeDark ? Colors.white54 : Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.isThemeDark ? Colors.white38 : Colors.black45,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: context.isThemeDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showTafsirPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Tafsir Resource",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: context.isThemeDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final res = _resources[index];
                    final bool isSelected = res['id'] == _selectedResourceId;
                    return ListTile(
                      title: Text(
                        res['name'],
                        style: TextStyle(
                          color: context.isThemeDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "${res['language_name'].toString().capitalize()} • ${res['author_name']}",
                        style: TextStyle(
                          color: context.isThemeDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF267B92)) : null,
                      onTap: () {
                        setState(() {
                          _selectedResourceId = res['id'];
                        });
                        Navigator.pop(context);
                        _fetchTafsir();
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
}
