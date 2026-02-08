// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  static const String _fontFamily = 'SF Pro';
  
  // ==================== DISPLAY ====================
  // For large hero titles
  static const display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    letterSpacing: 0.25,
    height: 1.2,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    letterSpacing: 0.15,
    height: 1.25,
  );
  
  // ==================== HEADLINES ====================
  // For section titles
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    letterSpacing: 0.15,
    height: 1.3,
  );
  
  static const h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  static const h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  // ==================== BODY TEXT ====================
  // For main content
  static const bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    letterSpacing: -0.4,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    letterSpacing: -0.2,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  // Body variants with different weights
  static const bodyLargeBold = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: -0.4,
    height: 1.5,
  );
  
  static const bodyMediumBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: -0.2,
    height: 1.5,
  );
  
  // ==================== LABELS ====================
  // For labels and UI elements
  static const labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    letterSpacing: -0.1,
    height: 1.3,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    letterSpacing: 0.1,
    height: 1.2,
  );
  
  // ==================== BUTTONS ====================
  static const button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: -0.4,
    height: 1.2,
  );
  
  static const buttonMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: -0.2,
    height: 1.2,
  );
  
  static const buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: -0.1,
    height: 1.2,
  );
  
  // ==================== SPECIAL ====================
  // Caption - For small annotations
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: 0,
    height: 1.3,
  );
  
  // Overline - For supertitles (ALL CAPS recommended)
  static const overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    letterSpacing: 1.5,
    height: 1.2,
  );
  
  // ==================== HELPERS ====================
  // Quick color variants
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}