import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.cormorantGaramondTextTheme();
    return MaterialApp(
      title: 'Ukiyo-e 匹配社交App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE2E0DE),
        textTheme: baseTextTheme.apply(
          bodyColor: const Color(0xFF3E2A2A),
          displayColor: const Color(0xFF3E2A2A),
        ),
      ),
      home: const HomePage(),
    );
  }
}
