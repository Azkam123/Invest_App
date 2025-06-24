// lib/models/crypto_model.dart
class Crypto {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final double totalVolume; // <--- PASTIKAN PROPERTI INI ADA

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.totalVolume, // <--- PASTIKAN INI ADA DI KONSTRUKTOR
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num).toDouble(),
      // Pastikan Anda melakukan parsing null-safe untuk nilai yang mungkin null dari API
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0, // <--- PASTIKAN PARSING INI ADA DAN NULL-SAFE
    );
  }
}
