class CompanyData {
  final String symbol;
  final double predictedClose;
  final String timestamp;

  CompanyData({required this.symbol, required this.predictedClose, required this.timestamp});

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      symbol: json['symbol'],
      predictedClose: json['predicted_close'].toDouble(),
      timestamp: json['timestamp'],
    );
  }
}

class CompanyResponse {
  final bool success;
  final CompanyData data;

  CompanyResponse({required this.success, required this.data});

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      success: json['success'],
      data: CompanyData.fromJson(json['data']),
    );
  }
}