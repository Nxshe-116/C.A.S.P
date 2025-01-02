class Notification {
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  Notification({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

 
  void toggleReadStatus() {
    isRead = !isRead;
  }

  String getFormattedTimestamp() {
    return "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}";
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      title: map['title'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
    );
  }
}

// Mock notifications for agriculture stock market app
final List<Notification> mockAgricultureNotifications = [
  Notification(
    title: "Sustainable Farming Adoption on the Rise",
    message: "More agricultural companies are adopting sustainable farming practices, driving growth in their stock prices. Stay updated on the latest trends.",
    timestamp: DateTime.now(),
  ),
  Notification(
    title: "Crop Yields Exceed Expectations",
    message: "Recent reports show that crop yields are exceeding expectations for several major agriculture companies, leading to a positive market response.",
    timestamp: DateTime.now().subtract(Duration(minutes: 30)),
  ),
  Notification(
    title: "Drought Impact on Agriculture Stocks",
    message: "The ongoing drought is affecting crop production. Several agriculture stocks may face short-term volatility as the situation develops.",
    timestamp: DateTime.now().subtract(Duration(hours: 2)),
  ),
  Notification(
    title: "New Trade Agreement Boosts Agricultural Exports",
    message: "A new trade agreement between countries is expected to boost agricultural exports, which could positively impact related stocks in the market.",
    timestamp: DateTime.now().subtract(Duration(hours: 6)),
  ),
  Notification(
    title: "Organic Farming Stocks Show Steady Growth",
    message: "Stocks of companies focusing on organic farming and eco-friendly practices are seeing steady growth. It's an opportune time to explore investments.",
    timestamp: DateTime.now().subtract(Duration(hours: 1)),
  ),
  Notification(
    title: "Pesticide Regulation Changes Impacting Agriculture Companies",
    message: "New regulations on pesticide usage are expected to affect agricultural companies' bottom lines. Keep an eye on market reactions to these changes.",
    timestamp: DateTime.now().subtract(Duration(days: 1)),
  ),
  Notification(
    title: "Agriculture Sector Performance Report Released",
    message: "The latest agriculture sector performance report has been released, showing significant growth in the organic and sustainable farming sectors.",
    timestamp: DateTime.now().subtract(Duration(days: 3)),
  ),
  Notification(
    title: "Climate Change Legislation Influences Agricultural Stocks",
    message: "New climate change legislation is expected to impact agricultural companies. Companies adapting to greener practices may benefit in the long run.",
    timestamp: DateTime.now().subtract(Duration(days: 4)),
  ),
];
