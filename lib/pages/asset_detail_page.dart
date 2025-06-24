// lib/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/models/crypto_detail_model.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:invest_app/utils/constants.dart';
import 'package:invest_app/models/news_article_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat if needed

class AssetDetailPage extends StatefulWidget {
  final Crypto crypto;
  const AssetDetailPage({super.key, required this.crypto});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> with SingleTickerProviderStateMixin {
  late Future<CryptoDetail> _cryptoDetailFuture;
  late TabController _tabController;

  late Future<List<NewsArticle>> _newsFuture;
  late Future<List<NewsArticle>> _analysisFuture;

  // URL untuk halaman trading Dupoin
  final String _dupoinTradingUrl = 'https://www.dupoin.co.id/promotion/pasar-finansial/?utm_source=investing&utm_campaign&subID=ENID_Dupoin_FCTradeNowA_Fluid_NGRST3774215681_OA_DFP__31a647279cd4d61a-1750674547411';

  @override
  void initState() {
    super.initState();
    _cryptoDetailFuture = ApiService().fetchCryptoDetail(widget.crypto.id);
    _tabController = TabController(length: 4, vsync: this);

    // Inisialisasi future untuk berita dan analisis
    _newsFuture = ApiService().fetchCryptoNews(widget.crypto.name);
    _analysisFuture = ApiService().fetchCryptoAnalysis(widget.crypto.name);
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = ApiService().fetchCryptoNews(widget.crypto.name);
    });
  }

  Future<void> _refreshAnalysis() async {
    setState(() {
      _analysisFuture = ApiService().fetchCryptoAnalysis(widget.crypto.name);
    });
  }

  // Fungsi untuk membuka URL dengan logging debug yang lebih baik
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    debugPrint('Attempting to launch URL: $url'); // Debugging: Log URL yang akan diluncurkan
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication); // Menggunakan externalApplication
        debugPrint('Successfully launched URL: $url'); // Debugging: Berhasil meluncurkan URL
      } else {
        if (!mounted) return;
        debugPrint('Could not launch URL: $url. Reason: canLaunchUrl returned false.'); // Debugging: Alasan kegagalan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka tautan: $url')), // Hardcode teks dengan URL
        );
      }
    } catch (e) {
      debugPrint('Exception during URL launch for $url: $e'); // Debugging: Tangkap exception
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat membuka tautan: $url, Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.network(
              widget.crypto.image,
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.currency_bitcoin, size: 24, color: Colors.white);
              },
            ),
            const SizedBox(width: 8),
            // Menggunakan Expanded dan Overflow.ellipsis untuk mencegah overflow pada nama kripto
            Expanded(
              child: Text(
                widget.crypto.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.crypto.symbol.toUpperCase(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.star_border)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gambaran Umum'),
            Tab(text: 'Teknis'),
            Tab(text: 'Berita'),
            Tab(text: 'Analisis'),
          ],
          isScrollable: true,
        ),
      ),
      body: FutureBuilder<CryptoDetail>(
        future: _cryptoDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Tidak ada data ditemukan.'));
          } else {
            final detail = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Overview
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Menggunakan Flexible dan overflow.ellipsis untuk harga agar tidak overflow
                                Flexible(
                                  child: Text(
                                    '\$${detail.currentPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10), // Spasi antar harga dan persentase
                                Flexible( // Menggunakan Flexible dan overflow.ellipsis untuk persentase agar tidak overflow
                                  child: Text(
                                    '${detail.priceChangePercentage24h.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: detail.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '03:53:04 - Real Time. Mata Uang dalam USD',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      Container(
                        height: 200,
                        color: Colors.grey[900],
                        child: Center(
                          child: detail.sparklineIn7dPrices != null && detail.sparklineIn7dPrices!.isNotEmpty
                              ? CustomPaint(
                                  painter: SparklinePainter(detail.sparklineIn7dPrices!),
                                  child: const SizedBox.expand(),
                                )
                              : const Text(
                                  'Grafik Harga Akan Muncul di Sini',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTimePeriodButton('1H'),
                          _buildTimePeriodButton('1D'),
                          _buildTimePeriodButton('1W'),
                          _buildTimePeriodButton('1M'),
                          _buildTimePeriodButton('1Y'),
                          _buildTimePeriodButton('Semua'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol "Mulai Perdagangan"
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _launchURL(_dupoinTradingUrl);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Mulai Perdagangan',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Rentang Hari', '\$${detail.low24h.toStringAsFixed(2)} - \$${detail.high24h.toStringAsFixed(2)}'),
                            _buildDetailRow('Rentang 52 Minggu', 'N/A'),
                            _buildDetailRow('Penutupan Sebelumnya', 'N/A'),
                            // Memastikan Market Cap juga tidak overflow
                            _buildDetailRow('Kapitalisasi Pasar', '\$${detail.marketCap.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tombol "Beli" dan "Jual"
                      _buildBuySellButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // TAB 2: Technical
                _buildTechnicalTab(),
                // TAB 3: News
                _buildNewsTab(),
                // TAB 4: Analysis
                _buildAnalysisTab(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTimePeriodButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: text == '1D' ? Colors.grey[700] : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(color: text == '1D' ? Colors.white : Colors.grey[400]),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Flexible( // Menggunakan Flexible untuk teks nilai
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1, // Batasi 1 baris
              overflow: TextOverflow.ellipsis, // Tampilkan elipsis jika overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuySellButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _launchURL(_dupoinTradingUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Beli',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _launchURL(_dupoinTradingUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Jual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Teknis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildTechnicalSummaryRow('1 Menit', 'Netral', isLocked: true),
          _buildTechnicalSummaryRow('5 Menit', 'Beli', isLocked: true),
          _buildTechnicalSummaryRow('15 Menit', 'Jual', isLocked: true),
          _buildTechnicalSummaryRow('30 Menit', 'Netral'),
          const SizedBox(height: 20),
          _buildTechnicalSummaryRow('Per Jam', 'Netral'),
          _buildTechnicalSummaryRow('Harian', 'Jual', isRed: true),
          _buildTechnicalSummaryRow('Mingguan', 'Beli', isGreen: true),
          _buildTechnicalSummaryRow('Bulanan', 'Beli', isGreen: true),
          const SizedBox(height: 20),
          const Text(
            'Ringkasan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildSummaryTable('Rata-rata Bergerak', 'Jual', 'Beli', 'Netral'),
          _buildSummaryTable('Indikator Teknis', 'Netral', 'Beli', 'Jual'),
          const SizedBox(height: 20),
          const Text(
            'Titik Pivot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Klasik', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Fibonacci', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Camarilla', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('S3: 90,000'),
                    Text('S3: 91,000'),
                    Text('S3: 92,000'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('S2: 95,000'),
                    Text('S2: 96,000'),
                    Text('S2: 97,000'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('S1: 100,000'),
                    Text('S1: 101,000'),
                    Text('S1: 102,000'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('P: 101,000', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('P: 102,000', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('P: 103,000', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('R1: 105,000'),
                    Text('R1: 106,000'),
                    Text('R1: 107,000'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('R2: 110,000'),
                    Text('R2: 111,000'),
                    Text('R2: 112,000'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('R3: 115,000'),
                    Text('R3: 116,000'),
                    Text('R3: 117,000'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildBuySellButtons(),
        ],
      ),
    );
  }

  Widget _buildTechnicalSummaryRow(String time, String status, {bool isLocked = false, bool isGreen = false, bool isRed = false}) {
    Color statusColor = Colors.grey;
    if (status == 'Beli') statusColor = Colors.green;
    if (status == 'Jual') statusColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(time, style: const TextStyle(fontSize: 16)),
              if (isLocked)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.lock, size: 16, color: Colors.blueGrey[700]),
                ),
              if (!isLocked)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.star, size: 16, color: Colors.orange),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTable(String title, String sell, String buy, String neutral) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryBox('Jual', '10', Colors.red),
            _buildSummaryBox('Beli', '3', Colors.green),
            _buildSummaryBox('Netral', '9', Colors.grey),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSummaryBox(String label, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 20,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada berita ditemukan.'));
          } else {
            final newsArticles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: newsArticles.length,
              itemBuilder: (context, index) {
                final article = newsArticles[index];
                return _buildNewsItem(
                  article.title,
                  article.source,
                  article.publishedAt,
                  article.imageUrl,
                  article.articleUrl,
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildNewsItem(String title, String source, String time, String? imageUrl, String? articleUrl) {
    return GestureDetector(
      onTap: () async {
        if (articleUrl != null) {
          final Uri uri = Uri.parse(articleUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tidak dapat membuka tautan: $articleUrl')),
            );
            debugPrint('Could not launch news link: $articleUrl');
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Tambahkan rounded corner
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    width: 100, // Ukuran disesuaikan
                    height: 80, // Ukuran disesuaikan
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 100, // Ukuran disesuaikan
                  height: 80, // Ukuran disesuaikan
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$source - $time',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return RefreshIndicator(
      onRefresh: _refreshAnalysis,
      child: FutureBuilder<List<NewsArticle>>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada analisis ditemukan.'));
          } else {
            final analysisArticles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: analysisArticles.length,
              itemBuilder: (context, index) {
                final article = analysisArticles[index];
                String avatarText = article.source.isNotEmpty ? article.source.substring(0, 1).toUpperCase() : '?';
                String avatarPlaceholder = 'https://placehold.co/100x100/A0A0A0/FFFFFF?text=$avatarText';

                return _buildNewsItem( // Menggunakan kembali _buildNewsItem untuk analisis
                  article.title,
                  article.source,
                  article.publishedAt,
                  article.imageUrl, // Gunakan imageUrl langsung, placeholder hanya untuk fallback
                  article.articleUrl,
                );
              },
            );
          }
        },
      ),
    );
  }
}

// SparklinePainter class (tetap sama)
class SparklinePainter extends CustomPainter {
  final List<double> prices;
  SparklinePainter(this.prices);

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    final priceRange = maxPrice == minPrice ? 1.0 : (maxPrice - minPrice);

    path.moveTo(0, size.height - ((prices[0] - minPrice) / priceRange) * size.height);

    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y = size.height - ((prices[i] - minPrice) / priceRange) * size.height;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
