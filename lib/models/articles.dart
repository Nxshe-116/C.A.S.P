import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String name;
  final String title;
  final String text;
  final DateTime createdAt;

  Article({
    required this.title,
    this.id = '',
    required this.name,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static String generateTitleFromText(String? text) {
    if (text == null || text.isEmpty) return 'Article Publication';

    final trimmedText = text.trim();
    final firstSentenceEnd = trimmedText.indexOf('.');

    if (firstSentenceEnd != -1) {
      String firstSentence = trimmedText.substring(0, firstSentenceEnd).trim();
      if (firstSentence.length > 50) {
        return '${firstSentence.substring(0, 50)}...';
      }
      return firstSentence;
    }

    return trimmedText.length > 50
        ? '${trimmedText.substring(0, 50)}...'
        : trimmedText;
  }

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime? parseCreatedAt(dynamic createdAt) {
      if (createdAt == null) return null;
      if (createdAt is Timestamp) return createdAt.toDate();
      if (createdAt is String) return DateTime.tryParse(createdAt);
      return null;
    }

    return Article(
      id: doc.id,
      name: data['name']?.toString() ?? 'Anonymous',
      title: data['title']?.toString() ??
          generateTitleFromText(data['text']?.toString()),
      text: data['text']?.toString() ?? '',
      createdAt: parseCreatedAt(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Article copyWith({
    String? id,
    String? name,
    String? title,
    String? text,
    DateTime? createdAt,
  }) {
    return Article(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Article{id: $id, name: $name, title: $title, text: $text, createdAt: $createdAt}';
  }
}
