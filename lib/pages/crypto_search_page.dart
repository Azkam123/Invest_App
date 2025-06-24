// lib/pages/crypto_search_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:invest_app/pages/asset_detail_page.dart'; // Untuk navigasi ke detail aset
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class CryptoSearchPage extends StatefulWidget {
  const CryptoSearchPage({super.key});

  @override
  State<CryptoSearchPage> createState() => _CryptoSearchPageState();
}

class _CryptoSearchPageState extends State<CryptoSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Crypto> _allCryptos = [];
  List<Crypto> _filteredCryptos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndInitializeCryptos(); // Ambil semua data kripto saat halaman dimuat
    _searchController.addListener(_onSearchChanged); // Dengarkan perubahan pada field pencarian
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil semua data kripto
  Future<void> _fetchAndInitializeCryptos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cryptos = await ApiService().fetchCryptos();
      setState(() {
        _allCryptos = cryptos;
        _filteredCryptos = cryptos; // Awalnya tampilkan semua kripto
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching all cryptos for search: $e');
    }
  }

  // Fungsi untuk memfilter kripto berdasarkan input pencarian
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCryptos = _allCryptos; // Jika input kosong, tampilkan semua
      } else {
        _filteredCryptos = _allCryptos.where((crypto) {
          return crypto.name.toLowerCase().contains(query) ||
                 crypto.symbol.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TextField langsung di dalam AppBar untuk fungsionalitas pencarian
        title: TextField(
          controller: _searchController,
          autofocus: true, // Otomatis fokus ke field pencarian saat halaman dibuka
          decoration: InputDecoration(
            hintText: 'Cari kripto...',
            hintStyle: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7)),
            border: InputBorder.none, // Hapus border default
            suffixIcon: _searchController.text.isNotEmpty // Tampilkan tombol clear jika ada teks
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor, fontSize: 18),
          cursorColor: Theme.of(context).appBarTheme.foregroundColor, // Warna kursor
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Tampilkan loading indicator
          : _error != null
              ? Center(child: Text('Error: $_error')) // Tampilkan pesan error
              : _filteredCryptos.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(child: Text('Tidak ada crypto ditemukan untuk pencarian ini.')) // Pesan jika tidak ada hasil
                  : ListView.builder(
                      itemCount: _filteredCryptos.length,
                      itemBuilder: (context, index) {
                        final crypto = _filteredCryptos[index];
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
                            subtitle: Text(crypto.symbol.toUpperCase()),
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
    );
  }
}
