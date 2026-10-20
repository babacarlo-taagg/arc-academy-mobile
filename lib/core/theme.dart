import 'package:flutter/material.dart';

/// Couleurs de l'appli. Provisoires : aucune charte ARC n'a été trouvée dans les dépôts.
/// Pour changer la charte, il suffit de modifier ces valeurs.
class ArcCouleurs {
  const ArcCouleurs._();

  static const primaire = Color(0xFF1F5C4A);
  static const primaireFonce = Color(0xFF143D31);
  static const primaireClair = Color(0xFFE3EFEA);

  /// Progression et réussite (jamais pour du texte : contraste trop faible).
  static const progression = Color(0xFF3FA372);
  static const attention = Color(0xFFB45309);
  static const attentionClair = Color(0xFFFFF4E5);

  static const encre = Color(0xFF15211D);
  static const texteDiscret = Color(0xFF4B5B55);
  static const fond = Color(0xFFF3F6F4);
  static const ligne = Color(0xFFDDE3E0);
}

/// Thème : texte grand par défaut, gros boutons (faciles à toucher après une garde), police Lexend
/// (conçue pour la lecture facile, licence OFL).
ThemeData construireTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: ArcCouleurs.primaire,
    onPrimary: Colors.white,
    primaryContainer: ArcCouleurs.primaireClair,
    onPrimaryContainer: ArcCouleurs.primaireFonce,
    secondary: ArcCouleurs.progression,
    onSecondary: Colors.white,
    secondaryContainer: ArcCouleurs.primaireClair,
    onSecondaryContainer: ArcCouleurs.primaireFonce,
    tertiary: ArcCouleurs.attention,
    onTertiary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: ArcCouleurs.encre,
    onSurfaceVariant: ArcCouleurs.texteDiscret,
    outline: Color(0xFFB8C4BF),
    outlineVariant: ArcCouleurs.ligne,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: 'Lexend');
  // Textes 8 % plus grands que d'habitude (lecture après une garde, écrans de 5 pouces).
  final typo = Typography.material2021();
  final texte = typo.englishLike
      .merge(typo.black)
      .apply(fontFamily: 'Lexend', fontSizeFactor: 1.08, bodyColor: ArcCouleurs.encre, displayColor: ArcCouleurs.encre);
  return base.copyWith(
    scaffoldBackgroundColor: ArcCouleurs.fond,
    textTheme: texte.copyWith(
      headlineSmall: texte.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: ArcCouleurs.primaireFonce),
      titleLarge: texte.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: texte.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: texte.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: texte.bodyMedium?.copyWith(height: 1.45),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ArcCouleurs.fond,
      foregroundColor: ArcCouleurs.encre,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ArcCouleurs.encre,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontFamily: 'Lexend', fontSize: 18, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontFamily: 'Lexend', fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ArcCouleurs.ligne),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ArcCouleurs.progression,
      linearTrackColor: ArcCouleurs.ligne,
    ),
  );
}
