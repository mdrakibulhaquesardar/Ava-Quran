import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PrayerNotificationsPage extends NyStatefulWidget {
  static RouteView path = ("/prayer-notifications", (_) => PrayerNotificationsPage());

  PrayerNotificationsPage({super.key}) : super(child: () => _PrayerNotificationsPageState());
}

class _PrayerNotificationsPageState extends NyPage<PrayerNotificationsPage> {
  final Map<String, bool> _notifications = {
    "Fajr": true,
    "Sunrise": false,
    "Dhuhr": true,
    "Asr": true,
    "Maghrib": true,
    "Isha": true,
  };

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
          "Prayer Notifications",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Daily Adhan Reminders"),
            const SizedBox(height: 12),
            _buildCard(
              _notifications.entries.map((e) {
                return Column(
                  children: [
                    _buildNotificationTile(e.key, e.value),
                    if (e.key != "Isha") _buildDivider(),
                  ],
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader("Notification Style"),
            const SizedBox(height: 12),
            _buildCard([
              _buildSimpleTile(Icons.volume_up_outlined, "Adhan Sound", "Default Makkah"),
              _buildDivider(),
              _buildSimpleTile(Icons.vibration_rounded, "Vibration", "Standard Pattern"),
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

  Widget _buildNotificationTile(String title, bool value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF267B92).withAlpha(15), shape: BoxShape.circle),
        child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF267B92), size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Switch.adaptive(
        value: value, 
        onChanged: (val) => setState(() => _notifications[title] = val), 
        activeColor: const Color(0xFF267B92)
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 65);
  }
}
