class Company {
  final String symbol;
  final String name;
  final double predictedClose;
  final String timestamp;

  Company({
    required this.symbol,
    required this.name,
    required this.predictedClose,
    required this.timestamp,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      symbol: json['symbol'],
      name: json['name'], // Assuming 'name' is part of the API response
      predictedClose: json['predicted_close'].toDouble(),
      timestamp: json['timestamp'],
    );
  }
}