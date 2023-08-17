import 'package:flutter/material.dart';
import 'package:purr_generator/cats/widget/cat_selection_page.dart';

void main() {
  runApp(const PurringApp());
}

class PurringApp extends StatelessWidget {
  const PurringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigeon Demo',
      theme: theme(),
      home: const CatSelectionPage(),
    );
  }
}

ThemeData theme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF24283B),
    scaffoldBackgroundColor: const Color(0xFF1E1E2C),
    cardColor: const Color(0xFF292D3E),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFA9B1D6)),
      displayMedium: TextStyle(color: Color(0xFFA9B1D6)),
      displaySmall: TextStyle(color: Color(0xFFA9B1D6)),
      headlineMedium: TextStyle(color: Color(0xFFA9B1D6)),
      headlineSmall: TextStyle(color: Color(0xFFA9B1D6)),
      titleLarge: TextStyle(color: Color(0xFFA9B1D6)),
      bodyLarge: TextStyle(color: Color(0xFFA9B1D6)),
      bodyMedium: TextStyle(color: Color(0xFFA9B1D6)),
      titleMedium: TextStyle(color: Color(0xFFA9B1D6)),
      titleSmall: TextStyle(color: Color(0xFFA9B1D6)),
      bodySmall: TextStyle(color: Color(0xFFA9B1D6)),
    ),
    buttonTheme: const ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      buttonColor: Color(0xFF3A3F58),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFA9B1D6),
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF24283B),
      iconTheme: IconThemeData(color: Color(0xFFA9B1D6)),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3A3F58), // FloatingActionButton background.
      foregroundColor: Color(0xFFA9B1D6),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFFA9B1D6),
      inactiveTrackColor: Color(0xFF3A3F58),
      thumbColor: Color(0xFFA9B1D6),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      brightness: Brightness.dark,
      secondary: const Color(0xFF3A3F58),
    ),
  );
}
