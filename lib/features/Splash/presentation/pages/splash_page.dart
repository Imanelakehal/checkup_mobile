import 'package:flutter/material.dart';
import 'dart:async';

/// SPLASH SCREEN - Fullscreen logo version
/// Logo image fills the entire screen

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
    
    // Navigate after 3 seconds
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final shouldShowOnboarding = await _checkFirstTime();
    final isLoggedIn = await _checkAuthStatus();
    
    if (!mounted) return;
    
    if (shouldShowOnboarding) {
      _navigateToOnboarding();
    } else if (isLoggedIn) {
      _navigateToHome();
    } else {
      _navigateToAuth();
    }
  }

  Future<bool> _checkFirstTime() async {
    return true; // For now, always show onboarding
  }

  Future<bool> _checkAuthStatus() async {
    return false; // For now, user not logged in
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NO background color - logo image provides background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox(
          // Fill entire screen
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/paramap_logo.png',
            // FILL the screen - image covers everything
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}