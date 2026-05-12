import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/home_page.dart';

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
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _finishOnboarding() {
    routeTo(HomePage.path, navigationType: NavigationType.pushAndRemoveUntil);
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2A3A),
              Color(0xFF03141C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TOP APP BAR SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Qurania",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
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

              // SLIDES SECTION
              Expanded(
                flex: 6,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: AssetImage(_slides[index]["image"]!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(76),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // BOTTOM CONTENT SECTION
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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

                      // Title
                      Text(
                        _slides[_currentPage]["title"]!,
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

                      // Subtitle Description
                      Text(
                        _slides[_currentPage]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      // Bottom Controls
                      Row(
                        children: [
                          // Back button (only show after first slide)
                          if (_currentPage > 0)
                            GestureDetector(
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
                            ),

                          // Primary Action Button
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
                                child: Text(
                                  _currentPage == _slides.length - 1
                                      ? "Get Started"
                                      : "Next",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
