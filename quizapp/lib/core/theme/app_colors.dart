import 'package:flutter/material.dart';

class AppPalette {
  final Color background;
  final Color backgroundAccent;
  final Color card;
  final Color primary;
  final Color secondary;
  final Color textDark;
  final Color textLight;
  final Color muted;
  final Color border;

  const AppPalette({
    required this.background,
    required this.backgroundAccent,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.textDark,
    required this.textLight,
    required this.muted,
    required this.border,
  });
}

class AppPalettes {
  static const violet = AppPalette(
    background: Color(0xFF2D237A),
    backgroundAccent: Color(0xFF5B4BC4),
    card: Colors.white,
    primary: Color(0xFF53D8F3),
    secondary: Color(0xFF8A6DFF),
    textDark: Color(0xFF25234A),
    textLight: Colors.white,
    muted: Color(0xFF8F8BAA),
    border: Color(0xFFEAE8F8),
  );

  static const pink = AppPalette(
    background: Color(0xFF7B2E6E),
    backgroundAccent: Color(0xFFE16BAE),
    card: Colors.white,
    primary: Color(0xFFFFC5E6),
    secondary: Color(0xFFFF8BC2),
    textDark: Color(0xFF4A2341),
    textLight: Colors.white,
    muted: Color(0xFFA5809A),
    border: Color(0xFFF7DCEA),
  );

  static const mint = AppPalette(
    background: Color(0xFF1F5E5B),
    backgroundAccent: Color(0xFF52B7A7),
    card: Colors.white,
    primary: Color(0xFFA8F1E7),
    secondary: Color(0xFF72D7C8),
    textDark: Color(0xFF1D3C3A),
    textLight: Colors.white,
    muted: Color(0xFF7E9F9B),
    border: Color(0xFFDDF4F0),
  );

  static const all = [violet, pink, mint];
}