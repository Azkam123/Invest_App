// lib/main.dart
import 'package:flutter/material.dart';
import 'package:invest_app/pages/home_page.dart';
import 'package:invest_app/pages/asset_list_page.dart';
import 'package:invest_app/pages/analytics_page.dart'; // Pastikan ini diimpor
import 'package:invest_app/pages/profile_page.dart';
import 'package:invest_app/utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Pastikan ini diinisialisasi ke 0 (tab pertama)

  // PASTIKAN URUTAN INI SESUAI DENGAN URUTAN BOTTOMNAVBARITEM
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),        // Index 0
    const AssetListPage(),   // Index 1
    const AnalyticsPage(),   // Index 2 (Halaman baru)
    const ProfilePage(),     // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Memperbarui indeks yang dipilih
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)), // Judul AppBar dinamis
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // Menampilkan widget sesuai indeks
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Aset',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Icon untuk Analisis
            label: 'Analisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex, // Menentukan item yang aktif
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Ketika item diklik, panggil _onItemTapped
        type: BottomNavigationBarType.fixed, // Penting untuk 4+ item
      ),
    );
  }

  // Fungsi pembantu untuk mendapatkan judul AppBar berdasarkan indeks
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return AppConstants.appName; // Atau 'Beranda' jika ingin lebih spesifik
      case 1:
        return AppConstants.assetListTitle;
      case 2:
        return 'Analisis Pasar'; // Judul untuk halaman Analisis
      case 3:
        return AppConstants.profilePageTitle;
      default:
        return AppConstants.appName;
    }
  }
}