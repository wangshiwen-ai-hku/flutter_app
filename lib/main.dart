
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/pages/home_page.dart';

// Global notifier for theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define Light Theme
    final baseTextTheme = GoogleFonts.josefinSansTextTheme(Theme.of(context).textTheme);
    const primaryColor = Color(0xFF992121);
    const lightBackgroundColor = Color(0xFFFBF9F7);
    final lightTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackgroundColor,
      primaryColor: primaryColor,
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFF4F4A45),
        displayColor: const Color(0xFF4F4A45),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: lightBackgroundColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F4A45)),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4F4A45),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFF8F5F3), // Original light mode color
      ),
    );

    // Define Dark Theme
    const darkBackgroundColor = Color(0xFF1C1C1E); // A slightly softer black
    const darkSurfaceColor = Color(0xFF2C2C2E);
    final darkTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackgroundColor,
      primaryColor: primaryColor,
      textTheme: baseTextTheme.apply(
        bodyColor: Colors.white.withOpacity(0.8),
        displayColor: Colors.white.withOpacity(0.8),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: darkBackgroundColor,
        surface: darkSurfaceColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white.withOpacity(0.8)),
      ),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Psycho',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentMode,
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
