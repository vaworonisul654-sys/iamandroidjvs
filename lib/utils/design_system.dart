import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  // Colors (iOS Parity)
  static const Color emerald = Color(0xFF00E08E);
  static const Color accentTeal = Color(0xFF00C2A6);
  static const Color background = Color(0xFF05070F);
  static const Color obsidianBlack = Color(0xFF010204);
  static const Color glassWhite = Color(0x0DFFFFFF); // 5%
  static const Color glassBorder = Color(0x26FFFFFF); // 15%
  
  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [obsidianBlack, Color(0xFF05070F), Color(0xFF0A0E1E)],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emerald, accentTeal],
  );

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white.withOpacity(0.95),
    letterSpacing: 0.5,
  );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.9),
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    color: Colors.white.withOpacity(0.9),
    height: 1.4,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: emerald.withOpacity(0.5),
  );

  // Premium Glassmorphism Widget
  static Widget glassCard({
    required Widget child,
    double radius = 18.0,
    EdgeInsets padding = const EdgeInsets.all(16.0),
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassWhite,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? glassBorder,
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  static BoxDecoration glassDecoration({double radius = 18.0}) {
    return BoxDecoration(
      color: glassWhite,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: glassBorder,
        width: 1.2,
      ),
    );
  }
}
