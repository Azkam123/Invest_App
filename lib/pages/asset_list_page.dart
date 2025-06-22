import 'package:flutter/material.dart';
import 'package:invest_app/pages/asset_detail_page.dart';
import 'package:invest_app/services/api_service.dart'; // Import API Service
import 'package:invest_app/models/crypto_model.dart'; // Import Model

class AssetListPage extends StatefulWidget {
  const AssetListPage({super.key});

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  late Future<List<Crypto>> futureCryptos;

  @override
  void initState() {
    super.initState();
    futureCryptos = ApiService().fetchCryptos(); // Panggil API saat inisialisasi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Aset'),
        automaticallyImplyLeading: false, // Sembunyikan tombol kembali di tab
      ),

       body: FutureBuilder<List<Crypto>>(
        future: futureCryptos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data aset.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Crypto crypto = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(crypto.image),
                    ),
                    title: Text(crypto.name),
                    subtitle: Text('Harga: \$${crypto.currentPrice.toStringAsFixed(2)}'),
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
            );
          }
        },
      ),
    );
  }
}