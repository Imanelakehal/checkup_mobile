import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:checkup_mobile/core/theme/app_typography.dart';
/// SIMPLE & BEAUTIFUL ONBOARDING - ParaMap
/// 
/// Flow:
/// 1. Welcome Page (welcome.svg + "Let's begin")
/// 2. Slide 1 (slide1.svg + text + progress + skip)
/// 3. Slide 2 (slide2.svg + text + progress + skip)
/// 4. Slide 3 (slide3.svg + text + progress + skip)
/// 5. Slide 4 (slide4.svg + text + progress + skip)
/// 6. Slide 5 (slide5.svg + "Sign Up" button) → Then Signup

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last slide → Go to signup
      Navigator.of(context).pushReplacementNamed('/signup');
    }
  }

  void _skipToSignup() {
    // Skip directly to signup
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  void _goToAuth() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildWelcomePage(),
            _buildSlide1(),
            _buildSlide2(),
            _buildSlide3(),
            _buildSlide4(),
            _buildSlide5(),
          ],
        ),
      ),
    );
  }

  /// WELCOME PAGE (Page 0) - No skip button
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          // Welcome SVG (big)
          _buildSvgImage(
            'assets/images/welcome.svg',
            width: 280,
            height: 280,
          ),
          
          const SizedBox(height: 40),
          
          // Welcome text - NOW USING AppTypography
          Text(
            'Welcome to ParaMap! Your smart guide to parapharmacy products and where to find them.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          
          const Spacer(flex: 2),
          
          // "Let's begin" button
          _buildGreenButton(
            text: "Let's begin",
            onPressed: _nextPage,
          ),
          
          const SizedBox(height: 16),
          
          // "Already have an account?" link
          GestureDetector(
            onTap: _goToAuth,
            child: RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF666666),
                ),
                children: [
                  TextSpan(
                    text: 'Sign in',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF344E41),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// SLIDE 1
  Widget _buildSlide1() {
    return _buildSlideTemplate(
      title: 'Welcome to ParaMap!',
      svgPath: 'assets/images/slide1.svg',
      description: 'Explore skincare, wellness, and care products available in nearby parapharmacies.',
      currentSlide: 1,
      showSkip: true,
    );
  }

  /// SLIDE 2
  Widget _buildSlide2() {
    return _buildSlideTemplate(
      title: 'Know where it is available.',
      svgPath: 'assets/images/slide2.svg',
      description: 'See which parapharmacies have your product before you go.',
      currentSlide: 2,
      showSkip: true,
    );
  }

  /// SLIDE 3
  Widget _buildSlide3() {
    return _buildSlideTemplate(
      title: 'Compare before you buy',
      svgPath: 'assets/images/slide3.svg',
      description: 'Check availability, prices, and alternatives to make better choices.',
      currentSlide: 3,
      showSkip: true,
    );
  }

  /// SLIDE 4
  Widget _buildSlide4() {
    return _buildSlideTemplate(
      title: 'Save time, shop smarter',
      svgPath: 'assets/images/slide4.svg',
      description: 'No more guessing. ParaMap helps you find the right product, fast.',
      currentSlide: 4,
      showSkip: true,
    );
  }

  /// SLIDE 5 (NEW) - Sign Up slide
  Widget _buildSlide5() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // Skip button (top right)
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _skipToSignup,
              child: Text(
                'Skip',
                style: AppTypography.labelLarge.copyWith(
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ),
          
          const Spacer(flex: 1),
          
          // Title - 36px Black weight
          Text(
            'Get started',
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // SVG
          _buildSvgImage(
            'assets/images/slide5.svg',
            width: 260,
            height: 260,
          ),
          
          const SizedBox(height: 40),
          
          // Description
          Text(
            'Sign up for ParaMap and easily locate parapharmacy products available near you.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
          
          const Spacer(flex: 2),
          
          // Sign Up button
          _buildGreenButton(
            text: 'Sign Up',
            onPressed: _skipToSignup,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// SLIDE TEMPLATE (for slides 1-4) with Skip button
  Widget _buildSlideTemplate({
    required String title,
    required String svgPath,
    required String description,
    required int currentSlide,
    bool showSkip = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // Skip button (top right)
          if (showSkip)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipToSignup,
                child: Text(
                  'Skip',
                  style: AppTypography.labelLarge.copyWith(
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 40),
          
          // Title - 36px Black weight
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display.copyWith(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          
          const Spacer(),
          
          // SVG in center
          _buildSvgImage(svgPath),
          
          const SizedBox(height: 40),
          
          // Description text
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
          
          const Spacer(),
          
          // Next button
          _buildGreenButton(
            text: 'Next',
            onPressed: _nextPage,
          ),
          
          const SizedBox(height: 24),
          
          // Progress bar (4 dots for slides 1-4)
          _buildProgressBar(currentSlide),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// SVG IMAGE WITH ERROR HANDLING
  Widget _buildSvgImage(String path, {double? width, double? height}) {
    return SvgPicture.asset(
      path,
      width: width ?? 260,
      height: height ?? 260,
      fit: BoxFit.contain,
      placeholderBuilder: (context) {
        return Container(
          width: width ?? 260,
          height: height ?? 260,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF344E41),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ SVG ERROR: $path - $error');
        return Container(
          width: width ?? 260,
          height: height ?? 260,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF9800),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: Color(0xFFFF9800),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'SVG not found:\n${path.split('/').last}',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// GREEN BUTTON (rounded)
  Widget _buildGreenButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF344E41),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.button,
        ),
      ),
    );
  }

  /// PROGRESS BAR (4 dots for slides 1-4 only)
  Widget _buildProgressBar(int currentSlide) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final slideNumber = index + 1;
        final isActive = slideNumber == currentSlide;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 32 : 8,
          decoration: BoxDecoration(
            color: isActive 
                ? const Color(0xFF344E41) 
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
