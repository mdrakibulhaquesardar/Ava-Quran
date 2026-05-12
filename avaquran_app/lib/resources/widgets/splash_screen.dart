import 'package:flutter/material.dart';
import '/resources/widgets/logo_widget.dart';
import 'dart:math';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Create a new instance of the MaterialApp
  static MaterialApp app() {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandAccent = Color(0xFF267B92);

    return Scaffold(
      body: Stack(
        children: [
          // 1. BASE BACKGROUND COLOR WITH SOFT GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF6FAF9),
                ],
              ),
            ),
          ),

          // 2. ISLAMIC PATTERN OVERLAY
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                "assets/images/pattern_light_soft.png",
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
                scale: 2.5, // Control pattern density
              ),
            ),
          ),

          // 3. RADIAL GLOW AURA
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    brandAccent.withAlpha(30),
                    brandAccent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          // 4. CORE CONTENT (LOCKED CENTER)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: brandAccent.withAlpha(20),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Logo(height: 100, width: 100),
                ),
                const SizedBox(height: 50),
                const AnimatedLoader(
                  size: 40,
                  color: brandAccent,
                ),
              ],
            ),
          ),

          // 5. BOTTOM BRANDING & VERSION
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/Icon_text.png",
                    height: 50,
                  ),
                  
                  const Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
                ),
          ),
        ],
      ),
    );
  }
}

class AnimatedLoader extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedLoader({
    super.key,
    this.size = 50.0,
    this.color = const Color(0xFF267B92),
  });

  @override
  createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPulsatingCircle(),
            _buildRotatingDots(),
          ],
        );
      },
    );
  }

  Widget _buildPulsatingCircle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingDots() {
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(8, (index) {
          final double angle = (index / 8) * 2 * pi;
          final double offset = widget.size * 0.35;
          return Transform(
              transform: Matrix4.identity()
                ..translateByDouble(
                  offset * cos(angle),
                  offset * sin(angle),
                  0,
                  1.0,
                ),
            child: _buildDot(index),
          );
        }),
      ),
    );
  }

  Widget _buildDot(int index) {
    final double dotSize = widget.size * 0.1;
    final double scaleFactor =
        0.5 + (1 - _controller.value + index / 8) % 1 * 0.5;
    return Transform.scale(
      scale: scaleFactor,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}
