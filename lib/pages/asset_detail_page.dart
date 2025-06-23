// lib/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:invest_app/models/crypto_model.dart';
import 'package:invest_app/models/crypto_detail_model.dart';
import 'package:invest_app/services/api_service.dart';
import 'package:invest_app/utils/constants.dart';
// import 'dart:developer'; // Hapus atau komen baris ini karena tidak digunakan lagi

class AssetDetailPage extends StatefulWidget {
  final Crypto crypto;
  const AssetDetailPage({super.key, required this.crypto});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> with SingleTickerProviderStateMixin {
  late Future<CryptoDetail> _cryptoDetailFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cryptoDetailFuture = ApiService().fetchCryptoDetail(widget.crypto.id);
    _tabController = TabController(length: 4, vsync: this);
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
            Text(widget.crypto.name),
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
            Tab(text: 'Overview'),
            Tab(text: 'Technical'),
            Tab(text: 'News'),
            Tab(text: 'Analysis'),
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
            return Center(child: Text('${AppConstants.apiErrorMessage}${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text(AppConstants.noDataMessage));
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
                                Text(
                                  '\$${detail.currentPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${detail.priceChangePercentage24h.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: detail.priceChangePercentage24h >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '03:53:04 - Real Time. Currency in USD',
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
                                  child: Container(),
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
                          _buildTimePeriodButton('1D'), // Panggilan sudah benar
                          _buildTimePeriodButton('1W'),
                          _buildTimePeriodButton('1M'),
                          _buildTimePeriodButton('1Y'),
                          _buildTimePeriodButton('5Y'),
                          _buildTimePeriodButton('Max'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur Trading belum diimplementasikan!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Start Trading',
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
                            _buildDetailRow('Day\'s Range', '\$${detail.low24h.toStringAsFixed(2)} - \$${detail.high24h.toStringAsFixed(2)}'), // Panggilan sudah benar
                            _buildDetailRow('52wk Range', 'N/A'),
                            _buildDetailRow('Previous Close', 'N/A'),
                            _buildDetailRow('Market Cap', '\$${detail.marketCap.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur Trading belum diimplementasikan!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Start Trading',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
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

  // **** Metode Pembantu berada di SINI, di dalam _AssetDetailPageState ****

  // Metode pembantu untuk tombol periode waktu
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

  // Metode pembantu untuk baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // **** Widget untuk Tab Technical ****
  Widget _buildTechnicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rangkuman Teknis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildTechnicalSummaryRow('1 Min.', 'Neutral', isLocked: true),
          _buildTechnicalSummaryRow('5 Min.', 'Unlock', isLocked: true),
          _buildTechnicalSummaryRow('15 Min.', 'Unlock', isLocked: true),
          _buildTechnicalSummaryRow('30 Min.', 'Neutral'),
          const SizedBox(height: 20),
          _buildTechnicalSummaryRow('Hourly', 'Neutral'),
          _buildTechnicalSummaryRow('Daily', 'Strong Sell', isRed: true),
          _buildTechnicalSummaryRow('Weekly', 'Strong Buy', isGreen: true),
          _buildTechnicalSummaryRow('Monthly', 'Strong Buy', isGreen: true),
          const SizedBox(height: 20),
          const Text(
            'Ringkasan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildSummaryTable('Moving Averages', 'Sell', 'Buy (3)', 'Sell (9)'),
          _buildSummaryTable('Technical Indicators', 'Neutral', 'Buy (3)', 'Sell (3)'),
          const SizedBox(height: 20),
          const Text(
            'Pivot Points',
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
                    Text('Classic', style: TextStyle(fontWeight: FontWeight.bold)),
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
    if (isGreen) statusColor = Colors.green;
    if (isRed) statusColor = Colors.red;

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
              // Perbaikan untuk deprecated withOpacity
              color: isGreen ? Colors.green.withAlpha((255 * 0.2).round()) : (isRed ? Colors.red.withAlpha((255 * 0.2).round()) : Colors.transparent),
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
            _buildSummaryBox('Sell', sell, Colors.red),
            _buildSummaryBox('Buy', buy, Colors.green),
            _buildSummaryBox('Neutral', neutral, Colors.grey),
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
        // Perbaikan untuk deprecated withOpacity
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

  // **** Widget untuk Tab News ****
  Widget _buildNewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNewsItem(
            'Bitcoin price today: falls to \$101k as US-Iran attack batter...',
            'Investing.com',
            '4h ago',
            'https://via.placeholder.com/100',
          ),
          _buildNewsItem(
            'Bitcoin falls 4% to \$99,237',
            'Reuters',
            '19h ago',
            'https://via.placeholder.com/100',
          ),
          _buildNewsItem(
            'DeFi Technologies Engages ShareIntel and Urvin to Enhanc...',
            'Investing.com',
            'Jun 21',
            'https://via.placeholder.com/100',
          ),
          _buildNewsItem(
            'Bitcoin price today: climbs to \$106k; Trump-Iran comman...',
            'Investing.com',
            'Jun 20',
            'https://via.placeholder.com/100',
          ),
          _buildNewsItem(
            'Crypto market sees surge in altcoin trading as Bitcoin ...',
            'CoinDesk',
            'Jun 19',
            'https://via.placeholder.com/100',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String title, String source, String time, String imageUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const SizedBox(height: 8),
                  Text(
                    '$source • $time',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // **** Widget untuk Tab Analysis ****
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisItem(
            'Double Shooting Star - A Pullback in the Making?',
            'Paulo Celig',
            '3h ago',
            'https://via.placeholder.com/100/0000FF/FFFFFF?text=PC',
          ),
          _buildAnalysisItem(
            'Bullish Despite War? Markets Split Between Fear and Optimism',
            'Geoff Bysshe',
            '5h ago',
            'https://via.placeholder.com/100/FF0000/FFFFFF?text=GB',
          ),
          _buildAnalysisItem(
            'Bitcoin Volatility Could Spill Over Into Stock Indices',
            'Declan Fallon',
            '5h ago',
            'https://via.placeholder.com/100/00FF00/FFFFFF?text=DF',
          ),
          _buildAnalysisItem(
            'Bitcoin Holds Firm Above \$105K as Geopolitical Storm Brews',
            'Prime XBT',
            'Jun 20',
            'https://via.placeholder.com/100/FFA500/FFFFFF?text=PX',
          ),
          _buildAnalysisItem(
            'Bitcoin: Calm Above \$105K Signals Accumulation as Bulls Prepare for Upside',
            'Günay Caymaz',
            'Jun 20',
            'https://via.placeholder.com/100/800080/FFFFFF?text=GC',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String author, String time, String avatarUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person),
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
                  const SizedBox(height: 8),
                  Text(
                    '$author • $time',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tombol Buy/Sell yang sama digunakan di Technical, News, Analysis
  Widget _buildBuySellButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buy feature not implemented yet!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Buy',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sell feature not implemented yet!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sell',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter (Pastikan ini ada di bagian bawah file yang sama, di luar kelas widget lainnya)
class SparklinePainter extends CustomPainter {
  final List<double> sparklineData;

  SparklinePainter(this.sparklineData);

  @override
  void paint(Canvas canvas, Size size) {
    if (sparklineData.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    double minY = sparklineData.reduce((a, b) => a < b ? a : b);
    double maxY = sparklineData.reduce((a, b) => a > b ? a : b);

    double scaleY = (maxY - minY) == 0 ? 0 : size.height / (maxY - minY);
    double stepX = size.width / (sparklineData.length - 1);

    path.moveTo(
      0,
      size.height - (sparklineData[0] - minY) * scaleY,
    );

    for (int i = 1; i < sparklineData.length; i++) {
      path.lineTo(
        i * stepX,
        size.height - (sparklineData[i] - minY) * scaleY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SparklinePainter && oldDelegate.sparklineData != sparklineData;
  }
}