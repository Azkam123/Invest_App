// lib/main.dart
import 'package:flutter/material.dart';
import 'package:invest_app/pages/onboarding_page.dart'; // Import OnboardingPage
import 'package:invest_app/widgets/main_app_screen.dart'; // Import MainAppScreen
// Imports halaman individual (home_page, markets_page, portfolio_page, profile_page)
// tidak lagi diperlukan di sini karena digunakan di MainAppScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Diubah menjadi ThemeMode.dark agar langsung gelap saat startup
  bool _showOnboarding = true; // State untuk mengontrol tampilan halaman onboarding

  // Fungsi untuk mengubah tema aplikasi
  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  // Fungsi untuk menandai bahwa onboarding telah selesai
  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner "DEBUG"
      title: 'Come Invest',
      // Tema Terang
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
          titleLarge: TextStyle(color: Colors.black87),
        ),
      ),
      // Tema Gelap
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey, // Warna primer yang berbeda untuk dark mode
        scaffoldBackgroundColor: Colors.black, // Latar belakang utama jadi hitam
        cardColor: Colors.grey[900], // Warna card di dark mode
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900], // Warna AppBar untuk dark mode
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode, // Menggunakan ThemeMode yang dikelola oleh state

      // Menampilkan OnboardingPage jika _showOnboarding true, jika tidak, tampilkan MainAppScreen
      home: _showOnboarding
          ? OnboardingPage(onGetStarted: _completeOnboarding, onThemeChanged: _setThemeMode)
          : MainAppScreen(onThemeChanged: _setThemeMode),
    );
  }
}
