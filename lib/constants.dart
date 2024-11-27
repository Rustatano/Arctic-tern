import 'package:flutter/material.dart';

const padding = 24.0;
const halfPadding = padding / 2;
const doublePadding = padding * 2;
const radius = 16.0;
const smallFontSize = 12.0;
const mediumFontSize = 20.0;
const bigFontSize = 30.0;

// global vars
bool darkMode = false;
ThemeData ligthThemeData = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 7, 114, 125),
    surface: Colors.white,
  ),
  useMaterial3: true,
);
ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 255, 89, 94),
    surface: Colors.white,
  ),
  useMaterial3: true,
);
ThemeData themeData = ligthThemeData;
ColorScheme colorScheme = ligthThemeData.colorScheme;

