// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/utils/constants.dart';

// Kelas untuk menangani kesalahan khusus API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
  }
}

class ApiService { // Pastikan nama kelas ini "ApiService"
  final String _baseUrl = AppConstants.coinGeckoBaseUrl;

  // Metode umum untuk melakukan request GET ke API
  Future<dynamic> _get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        String errorMessage = 'Terjadi kesalahan saat mengambil data.';
        if (response.statusCode == 404) {
          errorMessage = 'Endpoint tidak ditemukan.';
        } else if (response.statusCode == 429) {
          errorMessage = 'Terlalu banyak permintaan. Coba lagi nanti.';
        }
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      throw ApiException('Tidak ada koneksi internet atau masalah jaringan: ${e.message}');
    } catch (e) {
      throw ApiException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // Mengambil daftar mata uang kripto
  Future<List<Crypto>> fetchCryptos() async {
    try {
      final responseData = await _get(
        AppConstants.coinGeckoMarketsEndpoint,
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': AppConstants.defaultPerPageLimit.toString(),
          'page': '1',
          'sparkline': 'false',
        },
      );

      if (responseData is List) {
        return responseData.map((data) => Crypto.fromJson(data)).toList();
      } else {
        throw ApiException('Format respons API tidak sesuai.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mengurai data kripto: $e');
    }
  }

  // Contoh metode lain (misal: mengambil detail kripto)
  Future<Crypto> fetchCryptoDetail(String id) async {
    try {
      final responseData = await _get(
        '/coins/$id',
        queryParameters: {
          'localization': 'false',
          'tickers': 'false',
          'market_data': 'true',
          'community_data': 'false',
          'developer_data': 'false',
          'sparkline': 'true'
        },
      );
      return Crypto.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal memuat detail kripto: $e');
    }
  }
}