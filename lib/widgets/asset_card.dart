// lib/widgets/asset_card.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/pages/asset_detail_page.dart'; // Import halaman detail untuk navigasi

class AssetCard extends StatelessWidget {
  final Crypto crypto;
  final bool showPriceChange; // Properti opsional untuk mengontrol tampilan perubahan harga

  const AssetCard({
    super.key,
    required this.crypto,
    this.showPriceChange = true, // Defaultnya tampilkan perubahan harga
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell( // Menggunakan InkWell agar kartu bisa diklik dan ada efek riak
        onTap: () {
          // Navigasi ke halaman detail saat kartu diklik
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetailPage(crypto: crypto),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Gambar/Logo Kripto
              Image.network(
                crypto.image,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.currency_bitcoin, size: 40, color: Colors.grey); // Placeholder jika gambar gagal dimuat
                },
              ),
              const SizedBox(width: 15),

              // Nama dan Simbol Kripto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crypto.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      crypto.symbol.toUpperCase(),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Harga dan Perubahan Harga (Opsional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${crypto.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (showPriceChange) // Tampilkan hanya jika showPriceChange true
                    Text(
                      '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}