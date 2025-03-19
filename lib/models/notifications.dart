class Notifications {
  final String notifId;
  final String userId; // Add userId to associate notifications with a user
  final String title;
  final String message;
  final DateTime timestamp; // Keep this as DateTime
  bool isRead;

  Notifications( {
    required this.notifId,
    required this.userId, // Add userId as a required parameter
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
      'userId': userId, // Include userId in the map
       'notifId': notifId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to ISO string
      'isRead': isRead,
    };
  }

  factory Notifications.fromMap(Map<String, dynamic> map, String id) {
    return Notifications(
      notifId: map['notifId'],
      userId: map['userId'], // Parse userId from the map
      title: map['title'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']), // Parse ISO string to DateTime
      isRead: map['isRead'] ?? false,
    );
  } 




// final List<Notifications> mockAgricultureNotifications = [
//   Notifications(
//     userId: "user123", // Add userId
//     title: "Sustainable Farming Adoption on the Rise",
//     message:
//         "More agricultural companies are adopting sustainable farming practices, driving growth in their stock prices. Stay updated on the latest trends.",
//     timestamp: DateTime.now(),
//   ),
//   Notifications(
//     userId: "user123", // Add userId
//     title: "Crop Yields Exceed Expectations",
//     message:
//         "Recent reports show that crop yields are exceeding expectations for several major agriculture companies, leading to a positive market response.",
//     timestamp: DateTime.now().subtract(Duration(minutes: 30)),
//   ),
//   Notifications(
//     userId: "user456", // Add userId for a different user
//     title: "Drought Impact on Agriculture Stocks",
//     message:
//         "The ongoing drought is affecting crop production. Several agriculture stocks may face short-term volatility as the situation develops.",
//     timestamp: DateTime.now().subtract(Duration(hours: 2)),
//   ),
//   Notifications(
//     userId: "user456", // Add userId for a different user
//     title: "New Trade Agreement Boosts Agricultural Exports",
//     message:
//         "A new trade agreement between countries is expected to boost agricultural exports, which could positively impact related stocks in the market.",
//     timestamp: DateTime.now().subtract(Duration(hours: 6)),
//   ),
//   // Add more notifications with userId as needed
// ];

}