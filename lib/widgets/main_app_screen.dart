// lib/widgets/main_app_screen.dart
import 'package:flutter/material.dart';
import 'package:invest_app/pages/home_page.dart';
import 'package:invest_app/pages/profile_page.dart';
import 'package:invest_app/pages/markets_page.dart';
import 'package:invest_app/pages/portfolio_page.dart';

// Callback typedef untuk memberi tahu perubahan tema (dari main.dart)
typedef ThemeChangedCallback = void Function(ThemeMode themeMode);

class MainAppScreen extends StatelessWidget {
  final ThemeChangedCallback onThemeChanged;

  const MainAppScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const HomePage(),
            const MarketsPage(),
            const PortfolioPage(),
            ProfilePage(onThemeChanged: onThemeChanged), // Teruskan callback tema ke ProfilePage
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 56.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TabButton(icon: Icons.home, label: 'Beranda', index: 0),
                TabButton(icon: Icons.trending_up, label: 'Markets', index: 1),
                TabButton(icon: Icons.pie_chart, label: 'statistic', index: 2), // Atau 'Statistik' jika sudah diubah
                TabButton(icon: Icons.person, label: 'Profile', index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TabButton juga bisa diletakkan di sini atau di file terpisah jika ingin digunakan di luar.
// Untuk kemudahan, saya letakkan di sini untuk MainAppScreen.
class TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;

  const TabButton({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          DefaultTabController.of(context).animateTo(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24.0),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
