import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PeoplesPage extends NyStatefulWidget {
  static RouteView path = ("/peoples", (_) => PeoplesPage());

  PeoplesPage({super.key}) : super(child: () => _PeoplesPageState());
}

class _PeoplesPageState extends NyPage<PeoplesPage> {
  final Color _brandAccent = const Color(0xFF267B92);

  final List<Map<String, String>> _mockUsers = [
    {
      "name": "Sarah Ahmed",
      "bio": "Daily Quran Reflections & Journaling",
      "image": "assets/images/avatar_1.png",
      "followers": "1.2k",
    },
    {
      "name": "Zaid Al-Farooq",
      "bio": "Community Leader & Mentor",
      "image": "assets/images/avatar_2.png",
      "followers": "850",
    },
    {
      "name": "Aisha Rahman",
      "bio": "Islamic Art & Modesty Designer",
      "image": "assets/images/avatar_1.png",
      "followers": "2.4k",
    },
    {
      "name": "Omar H.",
      "bio": "Software Developer by day, Qari by night",
      "image": "assets/images/avatar_2.png",
      "followers": "1.5k",
    },
  ];

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND TEXTURE PRE-RENDERED
          Positioned.fill(
            child: Image.asset(
              "assets/images/pattern_light_soft.png",
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.60),
            ),
          ),

          // 2. MAIN PAGE CONTENT
          SafeArea(
            child: Column(
              children: [
                // CUSTOM HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                        ),
                      ),
                      
                      const Text(
                        "Community",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),

                      // Place holder to center text
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search people to follow...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
                        prefixIcon: Icon(Icons.search, color: _brandAccent, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),

                // LIST CONTENT
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _mockUsers.length,
                    itemBuilder: (context, index) {
                      final user = _mockUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, String> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          // User image
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _brandAccent.withAlpha(50), width: 2),
              image: DecorationImage(
                image: AssetImage(user["image"]!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Info details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user["bio"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${user["followers"]} followers",
                  style: TextStyle(
                    fontSize: 12,
                    color: _brandAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Follow Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _brandAccent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _brandAccent.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "Follow",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
