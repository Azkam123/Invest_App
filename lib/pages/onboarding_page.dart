// lib/pages/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/widgets/main_app_screen.dart'; // Import MainAppScreen

class OnboardingPage extends StatefulWidget {
  final VoidCallback onGetStarted;
  final Function(ThemeMode themeMode) onThemeChanged;

  const OnboardingPage({
    super.key,
    required this.onGetStarted,
    required this.onThemeChanged,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Durasi animasi
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero, // Posisi awal (tidak ada pergeseran)
      end: const Offset(0, -0.1), // Bergeser sedikit ke atas
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Kurva animasi yang halus
    ));

    // Mulai animasi berulang
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose(); // Pastikan controller dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang gelap untuk halaman onboarding
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menggunakan Image.asset untuk gambar lokal
              SlideTransition( // Menerapkan animasi di sini
                position: _offsetAnimation,
                child: Image.asset(
                  'assets/images/cryptocurrency.png', // <--- Ganti dengan path aset lokal Anda
                  width: 100,
                  height: 100,
                  // errorBuilder tidak diperlukan untuk Image.asset jika aset sudah benar
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Selamat Datang di InvestApp!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Mulai perjalanan investasi Anda dengan mudah dan cerdas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onGetStarted, // Panggil callback saat tombol ditekan
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Warna tombol utama
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Mulai Sekarang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
