// models/climate_data.dart
class ClimateData {
  final int year;
  final String month;
  final double rainfallAnomalyMm;
  final double averageTempC;

  ClimateData({
    required this.year,
    required this.month,
    required this.rainfallAnomalyMm,
    required this.averageTempC,
  });

  factory ClimateData.fromJson(Map<String, dynamic> json) {
    return ClimateData(
      year: json['year'],
      month: json['month'],
      rainfallAnomalyMm: json['rainfall_anomaly_mm'].toDouble(),
      averageTempC: json['average_temp_c'].toDouble(),
    );
  }
}