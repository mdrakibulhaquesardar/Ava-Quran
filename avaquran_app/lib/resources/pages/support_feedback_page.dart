import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SupportFeedbackPage extends NyStatefulWidget {
  static RouteView path = ("/support-feedback", (_) => SupportFeedbackPage());

  SupportFeedbackPage({super.key}) : super(child: () => _SupportFeedbackPageState());
}

class _SupportFeedbackPageState extends NyPage<SupportFeedbackPage> {
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
          "Support & Feedback",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Help Center"),
            const SizedBox(height: 12),
            _buildCard([
              _buildSupportTile(Icons.help_outline_rounded, "Frequently Asked Questions", "Common queries and answers"),
              _buildDivider(),
              _buildSupportTile(Icons.menu_book_outlined, "User Guidelines", "Learn how to use Ava Quran"),
              _buildDivider(),
              _buildSupportTile(Icons.mail_outline_rounded, "Contact Support", "Our team is here to help you"),
            ]),
            
            const SizedBox(height: 32),
            _buildSectionHeader("Feedback"),
            const SizedBox(height: 12),
            _buildCard([
              _buildSupportTile(Icons.star_outline_rounded, "Rate our App", "Love Ava? Let us know!"),
              _buildDivider(),
              _buildSupportTile(Icons.bug_report_outlined, "Report a Problem", "Spotted a bug? Send us a report"),
              _buildDivider(),
              _buildSupportTile(Icons.lightbulb_outline_rounded, "Suggest a Feature", "Help us make Ava better"),
            ]),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Version 1.0.2 (Build 42)",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildSupportTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.grey.shade700, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 65);
  }
}
