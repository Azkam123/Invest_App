import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invest_app/models/crypto_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<Crypto>> fetchCryptos() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Crypto.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat kripto: ${response.statusCode}');
    }
  }
  // Anda bisa menambahkan fungsi lain di sini untuk detail kripto, grafik, dll.
}