// lib/pages/asset_list_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/utils/constants.dart';
import 'package:invest_app/widgets/asset_card.dart'; // Import AssetCard

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
    futureCryptos = ApiService().fetchCryptos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.assetListTitle),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Crypto>>(
        future: futureCryptos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${AppConstants.apiErrorMessage}${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(AppConstants.noDataMessage));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Crypto crypto = snapshot.data![index];
                return AssetCard(crypto: crypto);
              },
            );
          }
        },
      ),
    );
  }
}