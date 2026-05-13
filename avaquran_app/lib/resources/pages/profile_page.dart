import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import '/resources/pages/quran_auth_page.dart';
import '/resources/pages/auth_page.dart';
import '/resources/pages/collections_page.dart';
import '/app/networking/api_service.dart';
import '/config/storage_keys.dart';

class ProfilePage extends NyStatefulWidget {
  static RouteView path = ("/profile", (_) => ProfilePage());

  ProfilePage({super.key}) : super(child: () => _ProfilePageState());
}

class _ProfilePageState extends NyPage<ProfilePage> {
  dynamic _user;

  @override
  get init => () {
    _user = _safeAuthData();
  };

  /// Safely resolve dynamic cache state even if returned as encoded serialized JSON
  dynamic _safeAuthData() {
    final dynamic rawData = Auth.data();
    if (rawData == null) return null;
    if (rawData is String && rawData.trim().startsWith("{")) {
      try {
         return jsonDecode(rawData);
      } catch (e) {
         return rawData; // Failback
      }
    }
    return rawData;
  }

  @override
  Widget view(BuildContext context) {
    // ULTIMATE SHIELD: Safely extract properties into scope variables to guarantee 0% crash risk
    final bool isValidMap = _user != null && _user is Map;
    final String userName = isValidMap ? (_user['name'] ?? "Ava User") : "Ava User";
    final String userEmail = isValidMap ? (_user['email'] ?? "No email available") : "No email available";
    final dynamic userQuranId = isValidMap ? _user['quranId'] : null;
    final String avatarSeed = isValidMap ? (_user['name'] ?? _user['email'] ?? "Unknown User") : "Unknown User";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA), // Premium soft offwhite
      body: Stack(
        children: [
          // 1. TOP SOFT PATTERN BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF267B92).withAlpha(40),
                    const Color(0xFFF8FBFA),
                  ],
                ),
              ),
            ),
          ),

          // 2. SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // CUSTOM APP BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(color: Colors.black.withAlpha(10)),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                          ),
                        ),
                        const Text(
                          "Profile settings",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: -0.2,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(color: Colors.black.withAlpha(10)),
                          ),
                          child: const Icon(Icons.more_horiz_rounded, size: 20, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // PROFILE HEADER SECTION
                  // Profile image with gradient border ring
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF267B92), Color(0xFF8EE4AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SvgPicture.string(
                          multiavatar(avatarSeed),
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Username & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF267B92), size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // STATS ROW (MAINTAINED)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("25", "DaysStreak"),
                        _buildDivider(),
                        _buildStatItem("19.4K", "Followers"),
                        _buildDivider(),
                        _buildStatItem("12", "Following"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // CONDITIONAL QURAN FOUNDATION BANNER
                  if (userQuranId == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF267B92), Color(0xFF1E6174)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF267B92).withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Enable Cloud Sync",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Connect your Quran.Foundation profile",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _triggerAccountLinking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF267B92),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Link", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // SETTINGS / ACTION LIST
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                        border: Border.all(color: Colors.black.withAlpha(5)),
                      ),
                      child: Column(
                        children: [
                          _buildSettingTile(
                            icon: Icons.person_outline_rounded,
                            color: Colors.blue.shade400,
                            title: "Account Information",
                            subtitle: "Manage your profile data",
                            isFirst: true,
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.bookmark_outline_rounded,
                            color: Colors.pink.shade400,
                            title: "Collections",
                            subtitle: "Saved Reminders & Reels",
                            onTap: () => routeTo(CollectionsPage.path),
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.palette_outlined,
                            color: Colors.teal.shade400,
                            title: "App Appearance",
                            subtitle: "Dark mode & Theme triggers",
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.notifications_none_outlined,
                            color: Colors.orange.shade400,
                            title: "Prayer Notifications",
                            subtitle: "Configure daily Adhan reminders",
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.lock_outline_rounded,
                            color: Colors.purple.shade400,
                            title: "Privacy & Security",
                            subtitle: "Passwords & Verification",
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.help_outline_rounded,
                            color: Colors.grey.shade600,
                            title: "Support & Feedback",
                            subtitle: "Reach the Ava Team",
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOGOUT ACTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleLogout,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "Sign Out",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Colors.red.shade300),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Bottom Clearance
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.black.withAlpha(15),
    );
  }

  Widget _buildTileDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade50,
      indent: 65,
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(24) : Radius.zero,
          bottom: isLast ? const Radius.circular(24) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to QuranAuthPage in link-mode and reloads profile data on success
  Future<void> _triggerAccountLinking() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => QuranAuthPage(isLinking: true),
        settings: const RouteSettings(arguments: {"isLinking": true}),
      ),
    );
    
    if (result == true) {
      // The user successfully connected and QuranAuthPage saved updated user to Auth storage.
      // Force local state re-hydration to render dynamic UI correctly.
      setState(() {
        _user = _safeAuthData();
      });
    }
  }

  /// Invalidate both server session and local device cache completely
  Future<void> _handleLogout() async {
    try {
      // 1. Dispatch backend invalidation packet (silent attempt)
      await ApiService().logoutUser();
    } catch (e) {
      NyLogger.error("Remote logout sync failed: $e");
    }

    // 2. Clear secured persistence slots on device
    await StorageKeysConfig.bearerToken.save(null);
    await StorageKeysConfig.refreshToken.save(null);
    
    // 3. Inform framework auth module
    await Auth.logout();
    
    // 4. Completely purge memory tree and return to Auth
    routeTo(AuthPage.path, navigationType: NavigationType.pushAndForgetAll);
    showToastInfo(description: "You've been safely signed out.");
  }
}
