// lib/models/news_article_model.dart

class NewsArticle {
  final String title;
  final String source;
  final String publishedAt; // <--- PASTIKAN NAMA INI SAMA DENGAN PENGGUNAAN
  final String? imageUrl;
  final String? articleUrl;

  NewsArticle({
    required this.title,
    required this.source,
    required this.publishedAt, // <--- PASTIKAN NAMA INI SAMA DENGAN PENGGUNAAN
    this.imageUrl,
    this.articleUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String? ?? 'No Title',
      source: json['source_id'] as String? ?? 'Unknown Source', // NewsData.io uses 'source_id'
      publishedAt: json['pubDate'] as String? ?? 'Unknown Date', // <--- MAPKAN DARI 'pubDate'
      imageUrl: json['image_url'] as String?,
      articleUrl: json['link'] as String?, // NewsData.io uses 'link' for article URL
    );
  }
}