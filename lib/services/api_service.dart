// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:invest_app/models/crypto_model.dart';
// import 'package:invest_app/utils/constants.dart'; // DIHAPUS: Unused import
import 'package:invest_app/models/crypto_detail_model.dart';
import 'package:invest_app/models/news_article_model.dart';

// Kelas untuk menangani kesalahan khusus API
class ApiService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3';
  final String _newsApiKey = 'pub_ae700cc88a194b7d83f817ff716d5449'; // API KEY ANDA
  final String _newsBaseUrl = 'https://newsdata.io/api/1/news';

  // Method yang sudah ada...
  Future<List<Crypto>> fetchCryptos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Crypto.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load cryptos - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load cryptos');
      }
    } catch (e) {
      debugPrint('Error fetching cryptos: $e'); // Menggunakan debugPrint
      throw Exception('Failed to load cryptos: $e');
    }
  }

  // Method yang sudah ada...
  Future<CryptoDetail> fetchCryptoDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/coins/$id?localization=false&sparkline=true'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return CryptoDetail.fromJson(data);
      } else {
        debugPrint('Failed to load crypto detail for $id - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load crypto detail for $id');
      }
    } catch (e) {
      debugPrint('Error fetching crypto detail: $e'); // Menggunakan debugPrint
      throw Exception('Failed to load crypto detail: $e');
    }
  }

  Future<List<NewsArticle>> fetchCryptoNews(String query) async {
    final Uri uri = Uri.parse('$_newsBaseUrl?apikey=$_newsApiKey&q=$query&language=en');
    debugPrint('Fetching news from URL: $uri'); // Menggunakan debugPrint

    try {
      final response = await http.get(uri);
      debugPrint('News API Response Status Code: ${response.statusCode}'); // Menggunakan debugPrint
      debugPrint('News API Response Body: ${response.body}'); // Menggunakan debugPrint

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          List<dynamic> articlesJson = data['results'] ?? [];
          debugPrint('Found ${articlesJson.length} news articles.'); // Menggunakan debugPrint
          return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
        } else {
          debugPrint('News API Response Status Not Success: ${data['status']}'); // Menggunakan debugPrint
          debugPrint('News API Response Message: ${data['message']}'); // Menggunakan debugPrint
          throw Exception('Failed to load crypto news: ${data['message'] ?? 'Unknown error from API'}');
        }
      } else {
        debugPrint('Failed to load news for $query. HTTP Status code: ${response.statusCode}'); // Menggunakan debugPrint
        debugPrint('Response body: ${response.body}'); // Menggunakan debugPrint
        throw Exception('Failed to load news for $query - HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception during API call for news ($query): $e'); // Menggunakan debugPrint
      throw Exception('Failed to load crypto news: $e');
    }
  }

  Future<List<NewsArticle>> fetchCryptoAnalysis(String query) async {
    final Uri uri = Uri.parse('$_newsBaseUrl?apikey=$_newsApiKey&q=$query analysis&language=en');
    debugPrint('Fetching analysis from URL: $uri'); // Menggunakan debugPrint

    try {
      final response = await http.get(uri);
      debugPrint('Analysis API Response Status Code: ${response.statusCode}'); // Menggunakan debugPrint
      debugPrint('Analysis API Response Body: ${response.body}'); // Menggunakan debugPrint

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          List<dynamic> articlesJson = data['results'] ?? [];
          debugPrint('Found ${articlesJson.length} analysis articles.'); // Menggunakan debugPrint
          return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
        } else {
          debugPrint('Analysis API Response Status Not Success: ${data['status']}'); // Menggunakan debugPrint
          debugPrint('Analysis API Response Message: ${data['message']}'); // Menggunakan debugPrint
          throw Exception('Failed to load crypto analysis: ${data['message'] ?? 'Unknown error from API'}');
        }
      } else {
        debugPrint('Failed to load analysis for $query. HTTP Status code: ${response.statusCode}'); // Menggunakan debugPrint
        debugPrint('Response body: ${response.body}'); // Menggunakan debugPrint
        throw Exception('Failed to load crypto analysis: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception during API call for analysis ($query): $e'); // Menggunakan debugPrint
      throw Exception('Failed to load crypto analysis: $e');
    }
  }
}
