import 'package:flutter/material.dart';

class ColoresApp {
  static const Color lavanda = Color(0xFFC9B5E0);
  static const Color violeta = Color(0xFF6061B6);
  static const Color azul = Color(0xFF00105B);
  static const Color fondo = Color(0xFFF9F8FC);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color borde = Color(0xFFDDD1EA);
  static const Color textoSecundario = Color(0xFF697186);

  static const OutlineInputBorder bordeEntrada = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: borde),
  );

  static ThemeData get tema {
    final esquema = ColorScheme.fromSeed(
      seedColor: violeta,
      primary: violeta,
      onPrimary: blanco,
      secondary: lavanda,
      onSecondary: azul,
      surface: fondo,
      onSurface: azul,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: violeta,
        foregroundColor: blanco,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blanco,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: bordeEntrada,
        enabledBorder: bordeEntrada,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: violeta, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFB3261E), width: 1.6),
        ),
        labelStyle: const TextStyle(color: textoSecundario),
        hintStyle: const TextStyle(color: textoSecundario),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: violeta,
          foregroundColor: blanco,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: violeta,
        foregroundColor: blanco,
      ),
      cardTheme: CardThemeData(
        color: blanco,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: const BorderSide(color: borde),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: azul,
        contentTextStyle: TextStyle(color: blanco),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
