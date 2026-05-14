import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import '/app/models/user.dart';

class AccountInfoPage extends NyStatefulWidget {
  static RouteView path = ("/account-info", (_) => AccountInfoPage());

  AccountInfoPage({super.key}) : super(child: () => _AccountInfoPageState());
}

class _AccountInfoPageState extends NyPage<AccountInfoPage> {
  User? _user;

  @override
  boot() async {
    _user = _safeAuthData();
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
    final User? user = _user ?? _safeAuthData();
    final String avatarSeed = user?.avatar ?? user?.name ?? user?.email ?? "Unknown User";
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Account Information",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // 1. AVATAR SECTION
            Center(
              child: Stack(
                children: [
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
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SvgPicture.string(
                          multiavatar(avatarSeed),
                          height: 110,
                          width: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF267B92),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 2. DATA FIELDS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Personal Details"),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard([
                    _buildInfoTile(
                      icon: Icons.person_outline_rounded,
                      label: "Display Name",
                      value: user?.name ?? "Not set",
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.alternate_email_rounded,
                      label: "Username",
                      value: "@${user?.username ?? 'unnamed'}",
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.mail_outline_rounded,
                      label: "Email Address",
                      value: user?.email ?? "Not available",
                    ),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader("Social Presence"),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard([
                    _buildInfoTile(
                      icon: Icons.notes_rounded,
                      label: "Biography",
                      value: user?.bio ?? "Share something about your journey...",
                      isLongText: true,
                    ),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader("Ecosystem Links"),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard([
                    _buildInfoTile(
                      icon: Icons.cloud_done_outlined,
                      label: "Quran.Foundation",
                      value: user?.quranId != null ? "Linked" : "Not Linked",
                      trailing: user?.quranId != null 
                        ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                        : const Text("Link now", style: TextStyle(color: Color(0xFF267B92), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ]),
                  
                  const SizedBox(height: 40),
                  
                  // DELETE ACCOUNT OPTION (Subtle)
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Request Account Deletion",
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.black.withAlpha(80),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.black.withAlpha(5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLongText = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF267B92).withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF267B92), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withAlpha(100),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade50,
      indent: 65,
    );
  }
}
