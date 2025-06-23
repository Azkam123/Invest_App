// lib/models/crypto_detail_model.dart
import 'dart:developer'; // Import ini untuk menggunakan log()

class CryptoDetail {
  final String id;
  final String name;
  final String symbol;
  final String image; // URL gambar
  final double currentPrice;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;
  final double marketCap;
  final List<double>? sparklineIn7dPrices; // Ubah ini menjadi List<double> untuk kemudahan

  CryptoDetail({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
    required this.marketCap,
    this.sparklineIn7dPrices,
  });

  factory CryptoDetail.fromJson(Map<String, dynamic> json) {
    // Gunakan log untuk melihat struktur JSON mentah
    log('Detail API Raw JSON: ${json.toString()}', name: 'CryptoDetail.fromJson');

    try {
      // Pastikan ada null-check dan casting yang benar
      final marketData = json['market_data'] as Map<String, dynamic>?;
      final currentPrice = marketData?['current_price']?['usd'] as num?;
      final priceChange24h = marketData?['price_change_percentage_24h'] as num?;
      final high24h = marketData?['high_24h']?['usd'] as num?;
      final low24h = marketData?['low_24h']?['usd'] as num?;
      final marketCap = marketData?['market_cap']?['usd'] as num?;

      List<double>? sparklinePrices;
      if (marketData != null &&
          marketData['sparkline_7d'] != null &&
          marketData['sparkline_7d']['price'] is List) {
        sparklinePrices = (marketData['sparkline_7d']['price'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }

      return CryptoDetail(
        id: json['id'] as String,
        name: json['name'] as String,
        symbol: json['symbol'] as String,
        image: (json['image']?['large'] ?? json['image']?['small'] ?? '') as String, // Pilih gambar yang tersedia
        currentPrice: currentPrice?.toDouble() ?? 0.0,
        priceChangePercentage24h: priceChange24h?.toDouble() ?? 0.0,
        high24h: high24h?.toDouble() ?? 0.0,
        low24h: low24h?.toDouble() ?? 0.0,
        marketCap: marketCap?.toDouble() ?? 0.0,
        sparklineIn7dPrices: sparklinePrices,
      );
    } catch (e, st) {
      log('Error parsing CryptoDetail: $e \nStackTrace: $st', name: 'CryptoDetail.fromJson');
      // Anda bisa melemparkan error lagi atau mengembalikan objek default
      throw FormatException('Failed to parse CryptoDetail from JSON: $e');
    }
  }
}