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
                child: Text(
                  "Verse ${item['verse_key'] ?? item['verse_number']}",
                  style: const TextStyle(
                    color: Color(0xFF267B92),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
