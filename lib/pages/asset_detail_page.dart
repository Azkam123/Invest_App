// lib/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart'; // Import model

class AssetDetailPage extends StatelessWidget {
  final Crypto crypto; // Menerima objek crypto dari halaman sebelumnya

  const AssetDetailPage({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crypto.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                crypto.image,
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Harga Saat Ini: \$${crypto.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Perubahan Harga 24j: ${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 18,
                color: crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text('Kapitalisasi Pasar: \$${crypto.marketCap.toStringAsFixed(2)}'),
            // Anda bisa menambahkan lebih banyak detail di sini, seperti grafik, deskripsi, dll.
          ],
        ),
      ),
    );
  }
}