import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/feed_page.dart';
import '/resources/pages/onboarding_page.dart';
import '/resources/pages/quran_auth_page.dart';
import '/app/networking/api_service.dart';
import '/config/storage_keys.dart';

class AuthPage extends NyStatefulWidget {
  static RouteView path = ("/auth", (_) => AuthPage());
  AuthPage({super.key}) : super(child: () => _AuthPageState());
}

class _AuthPageState extends NyPage<AuthPage> {
  bool _isLoading = false;

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  void _handleQuranAuth() {
    routeTo(QuranAuthPage.path);
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BEAUTIFUL FULL SCREEN BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/auth_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // 2. RICH DYNAMIC OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    Colors.black.withAlpha(100),
                    Colors.transparent,
                    const Color(0xFF03141C).withAlpha(220),
                    const Color(0xFF03141C),
                  ],
                ),
              ),
            ),
          ),

          // 3. AUTH CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  
                  // LOGO / BRANDING HEADLINE
                  const Text(
                    "Ava Quran",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your Spiritual Companion for the Holy Quran. Experience seamless synchronization and community reflections.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // PRIMARY AUTH BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF267B92).withAlpha(100),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleQuranAuth,
                        icon: const Icon(Icons.account_balance_wallet_rounded, size: 22),
                        label: const Text(
                          "Continue with Quran Foundation",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF267B92),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TERMS AND PRIVACY
                  Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
