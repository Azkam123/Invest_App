// lib/pages/portfolio_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:intl/intl.dart'; // Import untuk memformat angka (mis. mata uang)
import 'package:invest_app/pages/asset_detail_page.dart'; // Import untuk navigasi ke detail aset
import 'package:flutter/foundation.dart'; // For debugPrint

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  late Future<List<Crypto>> _cryptosFuture;

  @override
  void initState() {
    super.initState();
    _cryptosFuture = ApiService().fetchCryptos(); // Mengambil semua data kripto
  }

  // Fungsi untuk memformat angka mata uang agar mudah dibaca
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Statistic'),
        centerTitle: true,
        // Tidak perlu action search lagi di sini karena sudah ada di MarketsPage
      ),
      body: FutureBuilder<List<Crypto>>(
        future: _cryptosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error loading crypto statistics: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}\nGagal memuat data statistik Crypto.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data Crypto tersedia untuk statistik.'));
          } else {
            final List<Crypto> cryptos = snapshot.data!;

            // Hitung statistik ringkasan
            double totalMarketCap = 0;
            double totalVolume24h = 0;
            for (var crypto in cryptos) {
              totalMarketCap += crypto.marketCap;
              totalVolume24h += crypto.totalVolume;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu Ringkasan Statistik Global
                Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.grey[850], // Diubah ke warna arang
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Total Crypto', 
                          cryptos.length.toString(),
                          labelFontSize: 24, // Ukuran teks label lebih besar
                          valueFontSize: 18, // Ukuran teks nilai lebih besar
                          labelColor: Colors.white, // Warna teks putih
                          valueColor: Colors.green, // Diubah ke warna hijau
                        ),
                        _buildStatRow(
                          'Total Kapitalisasi Pasar', 
                          _formatCurrency(totalMarketCap),
                          labelFontSize: 20, // Ukuran teks label agak besar
                          valueFontSize: 16, // Ukuran teks nilai agak besar
                          labelColor: Colors.white70, // Warna teks putih agak transparan
                          valueColor: Colors.green, // Diubah ke warna hijau
                        ),
                        _buildStatRow(
                          'Volume Perdagangan 24h', 
                          _formatCurrency(totalVolume24h),
                          labelFontSize: 16, // Ukuran teks label agak besar
                          valueFontSize: 16, // Ukuran teks nilai agak besar
                          labelColor: Colors.white70, // Warna teks putih agak transparan
                          valueColor: Colors.green, // Diubah ke warna hijau
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Daftar Semua Crypto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded( // Agar ListView mengambil sisa ruang yang tersedia
                  child: ListView.builder(
                    itemCount: cryptos.length,
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(crypto.symbol.toUpperCase()),
                              Text('Market Cap: ${_formatCurrency(crypto.marketCap)}'),
                              Text('Vol 24h: ${_formatCurrency(crypto.totalVolume)}'),
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
                            // Navigasi ke halaman detail saat item diklik
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
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Widget pembantu untuk menampilkan baris statistik (dengan parameter font size & color)
  Widget _buildStatRow(String label, String value, {
    double labelFontSize = 16,
    double valueFontSize = 16,
    Color labelColor = Colors.black,
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w500, color: labelColor)),
          Text(value, style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}
