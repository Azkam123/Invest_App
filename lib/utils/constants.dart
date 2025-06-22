// lib/utils/constants.dart

class AppConstants {
  // --- API Constants ---
  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String coinGeckoMarketsEndpoint = '/coins/markets';
  // Jika Anda menggunakan API yang memerlukan API Key, letakkan di sini.
  // Contoh: static const String alphaVantageApiKey = 'YOUR_ALPHA_VANTAGE_API_KEY';

  // --- UI Constants ---
  static const String appName = 'InvestApp';
  static const String welcomeMessage = 'Selamat Datang, Investor!';
  static const String appDescription = 'Pantau pergerakan pasar dan aset favorit Anda.';
  static const String cryptoPopularTitle = 'Kripto Populer';
  static const String assetListTitle = 'Daftar Aset';
  static const String profilePageTitle = 'Profil Saya';
  static const String marketIndexTitle = 'Indeks Pasar Utama';

  // --- Error Messages ---
  static const String apiErrorMessage = 'Gagal memuat data: ';
  static const String noDataMessage = 'Tidak ada data yang tersedia.';
  static const String noCryptoDataMessage = 'Tidak ada data kripto.';

  // --- Other Constants ---
  static const int defaultCryptoLimit = 5; // Untuk Home Page
  static const int defaultPerPageLimit = 100; // Untuk Asset List Page
}