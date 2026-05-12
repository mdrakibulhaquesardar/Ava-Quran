import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/auth_page.dart';
import '/resources/pages/feed_page.dart';
import '/app/networking/api_service.dart';
import '/config/storage_keys.dart';

class OnboardingPage extends NyStatefulWidget {
  static RouteView path = ("/onboarding", (_) => OnboardingPage());

  OnboardingPage({super.key}) : super(child: () => _OnboardingPageState());
}

class _OnboardingPageState extends NyPage<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "Read Quran With\nPeace Daily",
      "desc": "Discover holy verses with translation audio\nbookmarks daily progress",
      "image": "assets/images/onboarding_1.png"
    },
    {
      "title": "Grow Faith With\nQuran Daily",
      "desc": "Strengthen faith through daily Quran reading\nlistening learning and reflection",
      "image": "assets/images/onboarding_2.png"
    },
    {
      "title": "Light Your Heart\nWith Quran",
      "desc": "Fill your heart with peace through daily\nQuran reading and reflection",
      "image": "assets/images/onboarding_3.png"
    }
  ];

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  void _goToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      _finishOnboarding();
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    }
  }

  Future<void> _finishOnboarding() async {
    String? token = await StorageKeysConfig.bearerToken.read();
    
    // Check if user is officially logged in right now
    if (token != null && token.isNotEmpty) {
      try {
        // Fire off the backend call to set completion
        await ApiService().updateOnboardingStatus(complete: true);
        // Update our local cache instantly
        await StorageKeysConfig.onboardingComplete.save(true);
      } catch (e) {
        NyLogger.error("Failed to push onboarding status to server: $e");
      }
      // Forward to global feed
      routeTo(FeedPage.path, navigationType: NavigationType.pushAndForgetAll);
    } else {
      // Not logged in, standard initial routing to Authentication gateway
      routeTo(AuthPage.path, navigationType: NavigationType.pushAndForgetAll);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAIN SWIPEABLE CONTENT (Background Image + Swiping Text)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  children: [
                    // FULL SCREEN BACKGROUND IMAGE
                    Positioned.fill(
                      child: Image.asset(
                        slide["image"]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // GRADIENT OVERLAY (Fades from top clear to deep dark bottom for text)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 0.8, 1.0],
                            colors: [
                              Colors.black.withAlpha(60), // Slight top dark for clock/bar
                              Colors.transparent,
                              const Color(0xFF03141C).withAlpha(180), // Dark gradient starts before text
                              const Color(0xFF03141C),               // Deep bottom
                            ],
                          ),
                        ),
                      ),
                    ),

                    // PAGE SPECIFIC SWIPING TEXT
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slide["title"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                slide["desc"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 2. STATIC OVERLAY CONTROLS (Top & Bottom Safe UI)
          SafeArea(
            child: Column(
              children: [
                // TOP BAR (STATIC)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(image: AssetImage("assets/images/Icon_text.png"), height: 40,),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const Spacer(),

                // BOTTOM NAVIGATION SECTION (STATIC)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF2CA5C4)
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Button Row
                      Row(
                        children: [
                          // Back Button Animated In/Out
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _currentPage > 0
                                ? GestureDetector(
                                    onTap: _goToPrevPage,
                                    child: Container(
                                      height: 56,
                                      width: 56,
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(26),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withAlpha(40),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_left,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Primary Expanded Button
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _goToNextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF267B92),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    _currentPage == _slides.length - 1
                                        ? "Get Started"
                                        : "Next",
                                    key: ValueKey(_currentPage == _slides.length - 1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
