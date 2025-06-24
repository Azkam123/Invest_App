// lib/pages/portfolio_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:invest_app/pages/asset_detail_page.dart';
import 'package:flutter/foundation.dart';

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
    _cryptosFuture = ApiService().fetchCryptos();
  }

  String _formatCurrency(double amount) {
    // Gunakan NumberFormat untuk memastikan formatting yang konsisten dan rapi
    // Menggunakan compactSimpleCurrency untuk angka besar, atau currency default untuk yang lebih kecil
    if (amount >= 1000000) { // Jika dalam jutaan atau miliaran
      return NumberFormat.compactSimpleCurrency(locale: 'en_US', name: '\$', decimalDigits: 2).format(amount);
    }
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Kripto'), // Hardcode teks
        centerTitle: true,
      ),
      body: FutureBuilder<List<Crypto>>(
        future: _cryptosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error loading crypto statistics: ${snapshot.error}');
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}\nGagal memuat data statistik kripto.')); // Hardcode teks
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data ditemukan.')); // Hardcode teks
          } else {
            final List<Crypto> cryptos = snapshot.data!;

            double totalMarketCap = 0;
            double totalVolume24h = 0;
            for (var crypto in cryptos) {
              totalMarketCap += crypto.marketCap;
              totalVolume24h += crypto.totalVolume;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.grey[850],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Total Kripto', // Hardcode teks
                          cryptos.length.toString(),
                          labelFontSize: 18,
                          valueFontSize: 18,
                          labelColor: Colors.white,
                          valueColor: Colors.green,
                        ),
                        _buildStatRow(
                          'Total Kapitalisasi Pasar', // Hardcode teks
                          _formatCurrency(totalMarketCap),
                          labelFontSize: 16,
                          valueFontSize: 16,
                          labelColor: Colors.white70,
                          valueColor: Colors.green,
                        ),
                        _buildStatRow(
                          'Volume Perdagangan 24j', // Hardcode teks
                          _formatCurrency(totalVolume24h),
                          labelFontSize: 16,
                          valueFontSize: 16,
                          labelColor: Colors.white70,
                          valueColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Daftar Semua Kripto', // Hardcode teks
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
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
                          title: Text(
                            crypto.name,
                            maxLines: 1, // Batasi 1 baris
                            overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crypto.symbol.toUpperCase(),
                                maxLines: 1, // Batasi 1 baris
                                overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
                              ),
                              Text(
                                'Kapitalisasi Pasar: ${_formatCurrency(crypto.marketCap)}', // Hardcode teks
                                maxLines: 1, // Batasi 1 baris
                                overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
                              ),
                              Text(
                                'Vol 24h: ${_formatCurrency(crypto.totalVolume)}', // Hardcode teks
                                maxLines: 1, // Batasi 1 baris
                                overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
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
                                maxLines: 1, // Batasi 1 baris
                                overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
                              ),
                              Text(
                                '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                                ),
                                maxLines: 1, // Batasi 1 baris
                                overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
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
                ),
              ],
            );
          }
        },
      ),
    );
  }

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
          Flexible( // Gunakan Flexible agar teks nilai tidak overflow
            child: Text(
              value,
              style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.bold, color: valueColor),
              maxLines: 1, // Batasi 1 baris
              overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
            ),
          ),
        ],
      ),
    );
  }
}
