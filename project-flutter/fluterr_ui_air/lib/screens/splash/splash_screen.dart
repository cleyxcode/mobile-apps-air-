import 'package:flutter/material.dart';
import 'dart:async';
import '../../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _pulseAnimation;
  double _loadingProgress = 0.0;
  String _loadingText = "Memuat...";

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _contentController.forward();
    });
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (mounted) {
        setState(() {
          if (_loadingProgress < 1.0) {
            _loadingProgress += 0.01;
            if (_loadingProgress < 0.25) {
              _loadingText = "Memuat komponen...";
            } else if (_loadingProgress < 0.5) {
              _loadingText = "Menghubungkan sensor...";
            } else if (_loadingProgress < 0.75) {
              _loadingText = "Menyiapkan AI Model...";
            } else {
              _loadingText = "Hampir siap...";
            }
          } else {
            timer.cancel();
            _navigateToApp();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToApp() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/app');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundDecorations(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    _buildAnimatedLogo(),
                    const SizedBox(height: 32),
                    _buildAnimatedTitle(),
                    const Spacer(flex: 3),
                    _buildLoadingSection(),
                    const Spacer(flex: 1),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: child,
          ),
        );
      },
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.eco_rounded, size: 48, color: AppColors.primary),
                  Positioned(
                    right: 22,
                    bottom: 22,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.water_drop_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 22,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.memory_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _titleOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _titleSlide.value),
            child: Column(
              children: [
                const Text(
                  "Siram Pintar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      "Penyiraman Cerdas dengan AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _loadingText,
              key: ValueKey(_loadingText),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _loadingProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${(_loadingProgress * 100).clamp(0, 100).toInt()}%",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology_rounded,
              size: 14, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(
            "Powered by K-Nearest Neighbor AI",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: _buildCircleDecor(200, 0.08),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _buildCircleDecor(280, 0.05),
        ),
        Positioned(
          top: 80,
          left: 30,
          child: Transform.rotate(
            angle: -0.3,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.eco_rounded, size: 80, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 140,
          right: 20,
          child: Transform.rotate(
            angle: 0.5,
            child: Opacity(
              opacity: 0.06,
              child: Icon(Icons.water_drop_rounded, size: 70, color: Colors.white),
            ),
          ),
        ),
        // Floating particles
        ...List.generate(6, (i) {
          final top = 50.0 + (i * 120.0) % (MediaQuery.of(context).size.height * 0.6);
          final left = 20.0 + (i * 73.0) % (MediaQuery.of(context).size.width * 0.8);
          return Positioned(
            top: top,
            left: left,
            child: Opacity(
              opacity: 0.1 + (i % 3) * 0.05,
              child: Container(
                width: 4 + (i % 3) * 2.0,
                height: 4 + (i % 3) * 2.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCircleDecor(double size, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}
