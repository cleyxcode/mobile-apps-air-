import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../widgets/bottom_navigation.dart';
import 'home/home_screen.dart';
import 'mode/mode_screen.dart';
import 'history/history_screen.dart';
import 'notifications/notifications_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      ModeScreen(),
      HistoryScreen(),
      NotificationsScreen(),
    ];
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    _fadeController.reset();
    setState(() => _currentIndex = index);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
