// lib/pages/markets_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart'; // Import model Crypto Anda
import 'package:invest_app/services/api_service.dart'; // Import ApiService Anda
import 'package:invest_app/pages/asset_detail_page.dart'; // Import AssetDetailPage untuk navigasi
import 'package:invest_app/pages/crypto_search_page.dart'; // Import CryptoSearchPage yang akan dibuat
import 'package:intl/intl.dart'; // Import for date formatting

class MarketsPage extends StatefulWidget {
  const MarketsPage({super.key});

  @override
  State<MarketsPage> createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage> {
  late Future<List<Crypto>> _cryptosFuture;

  @override
  void initState() {
    super.initState();
    _cryptosFuture = ApiService().fetchCryptos(); // Memanggil API untuk mengambil daftar kripto
  }

  // Fungsi untuk refresh data kripto
  Future<void> _refreshCryptos() async {
    setState(() {
      _cryptosFuture = ApiService().fetchCryptos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets Crypto'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CryptoSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Crypto>>(
        future: _cryptosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error loading cryptos: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}\nPastikan API Key Anda valid atau tidak melebihi batas request.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data kripto ditemukan.'));
          } else {
            final List<Crypto> cryptos = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshCryptos,
              child: ListView.builder(
                itemCount: cryptos.length, // Tidak perlu +1 lagi karena waktu ada di dalam item
                itemBuilder: (context, index) {
                  final crypto = cryptos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: Image.network(
                        crypto.image,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.currency_bitcoin, size: 40, color: Colors.blue);
                        },
                      ),
                      title: Text(crypto.name),
                      subtitle: Row( // Ubah subtitle menjadi Row untuk waktu dan simbol
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey), // Ikon jam
                          const SizedBox(width: 4),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final currentTime = DateFormat('HH:mm:ss').format(snapshot.data!);
                                return Text(
                                  currentTime,
                                  style: const TextStyle(fontSize: 14, color: Colors.green), // Warna hijau
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '| ${crypto.symbol.toUpperCase()}', // Simbol setelah waktu
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${crypto.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetDetailPage(crypto: crypto),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
