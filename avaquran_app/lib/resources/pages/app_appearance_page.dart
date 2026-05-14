import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AppAppearancePage extends NyStatefulWidget {
  static RouteView path = ("/app-appearance", (_) => AppAppearancePage());

  AppAppearancePage({super.key}) : super(child: () => _AppAppearancePageState());
}

class _AppAppearancePageState extends NyPage<AppAppearancePage> {
  bool _darkMode = false;
  String _selectedTheme = "System Default";

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
          "App Appearance",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Theme Settings"),
            const SizedBox(height: 12),
            _buildCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                value: _darkMode,
                onChanged: (val) => setState(() => _darkMode = val),
              ),
              _buildDivider(),
              _buildRadioTile("System Default"),
              _buildDivider(),
              _buildRadioTile("Light Theme"),
              _buildDivider(),
              _buildRadioTile("Dark Theme"),
            ]),
            
            const SizedBox(height: 32),
            _buildSectionHeader("Color Palette"),
            const SizedBox(height: 12),
            _buildCard([
              _buildColorTile("Emerald Green", const Color(0xFF267B92), true),
              _buildDivider(),
              _buildColorTile("Midnight Blue", const Color(0xFF1A1A2E), false),
              _buildDivider(),
              _buildColorTile("Deep Purple", Colors.purple.shade700, false),
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

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF267B92)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: const Color(0xFF267B92)),
    );
  }

  Widget _buildRadioTile(String title) {
    return RadioListTile<String>(
      value: title,
      groupValue: _selectedTheme,
      onChanged: (val) => setState(() => _selectedTheme = val!),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      activeColor: const Color(0xFF267B92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildColorTile(String title, Color color, bool isSelected) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF267B92)) : null,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 55);
  }
}
