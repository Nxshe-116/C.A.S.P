class MonthlyPrediction {
  final int weekNumber;
  final double actualPrice;
  final double normalPrediction;
  final double? climatePrediction;
  final double? climateImpactPercent;

  MonthlyPrediction({
    required this.weekNumber,
    required this.actualPrice,
    required this.normalPrediction,
    this.climatePrediction,
    this.climateImpactPercent,
  });

  factory MonthlyPrediction.fromJson(Map<String, dynamic> json) {
    return MonthlyPrediction(
      weekNumber: json['week_number'],
      actualPrice: json['actual_price'].toDouble(),
      normalPrediction: json['normal_prediction'].toDouble(),
      climatePrediction: json['climate_prediction']?.toDouble(),
      climateImpactPercent: json['climate_impact_percent']?.toDouble(),
    );
  }
}

class PredictionChartData {
  final DateTime date;
  final double actualPrice;
  final double normalPrediction;
  final double? climatePrediction;

  PredictionChartData({
    required this.date,
    required this.actualPrice,
    required this.normalPrediction,
    this.climatePrediction,
  });
}