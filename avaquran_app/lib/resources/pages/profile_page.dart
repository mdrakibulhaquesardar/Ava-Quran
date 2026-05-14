import 'dart:convert';
import '/resources/pages/account_info_page.dart';
import '/resources/pages/app_appearance_page.dart';
import '/resources/pages/prayer_notifications_page.dart';
import '/resources/pages/privacy_security_page.dart';
import '/resources/pages/support_feedback_page.dart';
import 'package:avaquran_app/app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  User? _user;

  @override
  boot() async {
    _user = _safeAuthData();
    _refreshProfile();
  }

  /// Fetches fresh user data from server to update stats (streak, followers etc)
  Future<void> _refreshProfile() async {
    User? freshUser = await api<ApiService>((request) => request.fetchCurrentUser());
    if (freshUser != null) {
      setState(() {
        _user = freshUser;
      });
      // Sync back to local storage
      await Auth.authenticate(data: freshUser);
      await StorageKeysConfig.user.save(jsonEncode(freshUser.toJson()));
    }
  }

  /// Helper to format large numbers (e.g. 19400 -> 19.4K)
  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) {
      double k = count / 1000;
      return "${k.toStringAsFixed(k < 10 ? 1 : 0)}K";
    }
    return count.toString();
  }

  /// Safely resolve dynamic cache state even if returned as encoded serialized JSON
  User? _safeAuthData() {
    final dynamic rawData = Auth.data();
    if (rawData == null) return null;
    
    // If it's already a User model, return it directly
    if (rawData is User) {
      return rawData;
    }
    
    Map<String, dynamic>? data;
    if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else if (rawData is String && rawData.trim().startsWith("{")) {
      try {
         data = jsonDecode(rawData);
      } catch (e) {
         return null;
      }
    }
    
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  @override
  Widget view(BuildContext context) {
    // RESOLVE: Get the typed user model either from state or fresh from storage
    final User? user = _user ?? _safeAuthData();
    
    final String userName = user?.name ?? "Ava User";
    final String userEmail = user?.email ?? "No email available";
    final String avatarSeed = user?.avatar ?? user?.name ?? user?.email ?? "Unknown User";

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

                  // STATS ROW (REAL DATA)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("${user?.currentStreak ?? 0}", "DaysStreak"),
                        _buildDivider(),
                        _buildStatItem(_formatCount(user?.followersCount ?? 0), "Followers"),
                        _buildDivider(),
                        _buildStatItem("${user?.followingCount ?? 0}", "Following"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
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
                            onTap: () => routeTo(AccountInfoPage.path),
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
                            onTap: () => routeTo(AppAppearancePage.path),
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.notifications_none_outlined,
                            color: Colors.orange.shade400,
                            title: "Prayer Notifications",
                            subtitle: "Configure daily Adhan reminders",
                            onTap: () => routeTo(PrayerNotificationsPage.path),
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.lock_outline_rounded,
                            color: Colors.purple.shade400,
                            title: "Privacy & Security",
                            subtitle: "Passwords & Verification",
                            onTap: () => routeTo(PrivacySecurityPage.path),
                          ),
                          _buildTileDivider(),
                          _buildSettingTile(
                            icon: Icons.help_outline_rounded,
                            color: Colors.grey.shade600,
                            title: "Support & Feedback",
                            subtitle: "Reach the Ava Team",
                            isLast: true,
                            onTap: () => routeTo(SupportFeedbackPage.path),
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

  /// Invalidate both server session and local device cache completely
  Future<void> _handleLogout() async {
    try {
      // 1. Dispatch backend invalidation packet (silent attempt)
      await ApiService().logoutUser();
    } catch (e) {
      NyLogger.error("Remote logout sync failed: $e");
    }

    // 2. Clear secured persistence slots on device via SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('SK_BEARER_TOKEN');
    await prefs.remove('SK_REFRESH_TOKEN');
    
    // 3. Inform framework auth module
    await Auth.logout();
    
    // 4. Completely purge memory tree and return to Auth
    routeTo(AuthPage.path, navigationType: NavigationType.pushAndForgetAll);
    showToastInfo(description: "You've been safely signed out.");
  }
}
