import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PrivacySecurityPage extends NyStatefulWidget {
  static RouteView path = ("/privacy-security", (_) => PrivacySecurityPage());

  PrivacySecurityPage({super.key}) : super(child: () => _PrivacySecurityPageState());
}

class _PrivacySecurityPageState extends NyPage<PrivacySecurityPage> {
  bool _biometric = true;

  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
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
          "Privacy & Security",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Account Security"),
            const SizedBox(height: 12),
            _buildCard([
              _buildActionTile(Icons.lock_reset_rounded, "Change Password", "Last changed 3 months ago"),
              _buildDivider(),
              _buildActionTile(Icons.verified_user_outlined, "Two-Factor Auth", "Enable for extra protection"),
              _buildDivider(),
              _buildSwitchTile(Icons.fingerprint_rounded, "Biometric Login", _biometric, (val) => setState(() => _biometric = val)),
            ]),
            
            const SizedBox(height: 32),
            _buildSectionHeader("Data & Privacy"),
            const SizedBox(height: 12),
            _buildCard([
              _buildActionTile(Icons.visibility_off_outlined, "Profile Visibility", "Public (Everyone)"),
              _buildDivider(),
              _buildActionTile(Icons.history_rounded, "Search History", "Clear your local activity"),
              _buildDivider(),
              _buildActionTile(Icons.file_download_outlined, "Download My Data", "Request a copy of your records"),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(color: Colors.black.withAlpha(80), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.black.withAlpha(5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.purple.shade400),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.purple.shade400),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: Colors.purple.shade400),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 65);
  }
}
