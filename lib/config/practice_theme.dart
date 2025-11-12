import 'package:flutter/material.dart';

/// Theme configuration for the Practice Flow screens
/// Contains colors, text styles, and spacing constants
class PracticeTheme {
  // Primary Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Greys
  static const Color grey50 = Color(0xFFF5F5F5); // Normal pill background
  static const Color grey100 = Color(0xFFEDEDED); // Pill border
  static const Color grey300 = Color(0xFFD9D9D9); // Inactive stepper
  static const Color grey600 = Color(0xFF7A7A7A); // Subtext

  // Accent
  static const Color accentBlue = Color(0xFF007AFF); // Active canvas border

  // Spacing
  static const double pagePadding = 24.0;
  static const double verticalSpacing = 16.0;
  static const double pillSpacing = 12.0;

  // Border Radius
  static const double pillRadius = 100.0;
  static const double cardRadius = 16.0;

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 200);
}

/// Text styles for Practice Flow screens
class PracticeTextStyles {
  // Heading - Screen titles
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PracticeTheme.primaryBlack,
    letterSpacing: -0.3,
  );

  // Subtext - Helper text below titles
  static const TextStyle subtext = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: PracticeTheme.grey600,
    height: 1.4,
  );

  // Pill button (normal state)
  static const TextStyle pillText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: PracticeTheme.primaryBlack,
  );

  // Pill button (selected state)
  static const TextStyle pillTextSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PracticeTheme.primaryWhite,
  );

  // Cancel button
  static const TextStyle cancelButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: PracticeTheme.primaryBlack,
  );

  // Accordion title
  static const TextStyle accordionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: PracticeTheme.primaryBlack,
  );

  // Accordion subtitle (normal)
  static const TextStyle accordionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PracticeTheme.grey600,
  );

  // Accordion subtitle (selected)
  static const TextStyle accordionSubtitleSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PracticeTheme.primaryBlack,
  );
}

