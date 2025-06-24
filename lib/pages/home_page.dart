// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/utils/constants.dart';
import 'package:invest_app/widgets/asset_card.dart'; // Import AssetCard
import 'package:intl/intl.dart'; // Import for date formatting

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Crypto>> _topCryptosFuture;

  @override
  void initState() {
    super.initState();
    _topCryptosFuture = ApiService().fetchCryptos();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.welcomeMessage,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                AppConstants.appDescription,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              const Text(
                AppConstants.cryptoPopularTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              FutureBuilder<List<Crypto>>(
                future: _topCryptosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${AppConstants.apiErrorMessage}${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text(AppConstants.noCryptoDataMessage));
                  } else {
                    final topCryptos = snapshot.data!.take(AppConstants.defaultCryptoLimit).toList();
                    
                    return Column(
                      children: topCryptos.map((crypto) {
                        return AssetCard(crypto: crypto, showPriceChange: true);
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),

              const Text(
                AppConstants.marketIndexTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildMarketIndexCard('S&P 500', '+0.5%', Colors.green),
              _buildMarketIndexCard('NASDAQ', '-0.2%', Colors.red),
              _buildMarketIndexCard('Nikkei 225', '+1.1%', Colors.green),
              
              const SizedBox(height: 20.0), // Berikan sedikit ruang di bagian bawah
              // Waktu global di paling bawah dihapus dari sini karena akan per crypto
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketIndexCard(String name, String change, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              change,
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
