// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/utils/constants.dart'; // Import konstanta

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkModeEnabled = false;
  bool _areNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    // HAPUS Scaffold dan AppBar dari sini. Hanya kembalikan isi body-nya.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nama Pengguna',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'pengguna@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Pengaturan Aplikasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: _isDarkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isDarkModeEnabled = value;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mode Gelap: ${value ? 'Aktif' : 'Nonaktif'}')),
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Notifikasi'),
              value: _areNotificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _areNotificationsEnabled = value;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notifikasi: ${value ? 'Aktif' : 'Nonaktif'}')),
                  );
                });
              },
            ),
            ListTile(
              title: const Text('Bahasa'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur ubah bahasa belum diimplementasikan.')),
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              'Bantuan & Dukungan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQ (Pertanyaan Umum)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka FAQ...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support_outlined),
              title: const Text('Hubungi Dukungan'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka kontak dukungan...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Aplikasi Investasi. Semua hak dilindungi undang-undang.',
                  children: [
                    const Text('Aplikasi ini dibuat sebagai contoh penggunaan Flutter dan API publik.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}