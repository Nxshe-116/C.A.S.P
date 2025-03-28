class RealTimePrediction {
  final String symbol;
  final double currentPrediction;
  final double? previousPrediction;
  final DateTime timestamp;

  RealTimePrediction({
    required this.symbol,
    required this.currentPrediction,
    this.previousPrediction,
    required this.timestamp,
  });

  factory RealTimePrediction.fromJson(Map<String, dynamic> json) {
    return RealTimePrediction(
      symbol: json['symbol'],
      currentPrediction: (json['current_prediction'] as num).toDouble(),
      previousPrediction: json['previous_prediction'] != null
          ? (json['previous_prediction'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoricalPrediction {
  final String date;
  final double predictedClose;
  final double actualClose;

  HistoricalPrediction({
    required this.date,
    required this.predictedClose,
    required this.actualClose,
  });

  factory HistoricalPrediction.fromJson(Map<String, dynamic> json) {
    return HistoricalPrediction(
      date: json['date'],
      predictedClose: (json['predicted_close'] as num).toDouble(),
      actualClose: (json['actual_close'] as num).toDouble(),
    );
  }
}

class FuturePrediction {
  final int week;
  final double predictedClose;

  FuturePrediction({
    required this.week,
    required this.predictedClose,
  });

  factory FuturePrediction.fromJson(Map<String, dynamic> json) {
    return FuturePrediction(
      week: json['week'],
      predictedClose: (json['predicted_close'] as num).toDouble(),
    );
  }
}

class AgriculturalPrediction {
  final String symbol;
  final double currentPrediction;
  final double basePrice;
  final String climateAdjustment;
  final Map<String, dynamic> climateReport;
  final Map<String, dynamic> stressFactors;
  final String timestamp;

  AgriculturalPrediction({
    required this.symbol,
    required this.currentPrediction,
    required this.basePrice,
    required this.climateAdjustment,
    required this.climateReport,
    required this.stressFactors,
    required this.timestamp,
  });

  factory AgriculturalPrediction.fromJson(Map<String, dynamic> json) {
    return AgriculturalPrediction(
      symbol: json['symbol'],
      currentPrediction: (json['current_prediction'] as num).toDouble(),
      basePrice: (json['base_price'] as num).toDouble(),
      climateAdjustment: json['climate_adjustment'],
      climateReport: json['climate_report'],
      stressFactors: json['stress_factors'],
      timestamp: json['timestamp'],
    );
  }
}

class Prediction {
  final String symbol;
  final double currentPrediction;
  final List<WeeklyPrediction> weeklyPredictions;

  Prediction({
    required this.symbol,
    required this.currentPrediction,
    required this.weeklyPredictions,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      symbol: json['symbol'],
      currentPrediction: (json['current_prediction'] as num).toDouble(),
      weeklyPredictions: List<WeeklyPrediction>.from(
          json['weekly_predictions'].map((x) => WeeklyPrediction.fromJson(x))),
    );
  }
}

class PredictionWithClimate {
  final String symbol;
  final double currentPrediction;
  final List<WeeklyPrediction> weeklyPredictions;
  final ClimateMetrics climateMetrics;

  PredictionWithClimate({
    required this.symbol,
    required this.currentPrediction,
    required this.weeklyPredictions,
    required this.climateMetrics,
  });

  factory PredictionWithClimate.fromJson(Map<String, dynamic> json) {
    return PredictionWithClimate(
      symbol: json['symbol'],
      currentPrediction: (json['current_prediction'] as num).toDouble(),
      weeklyPredictions: List<WeeklyPrediction>.from(
          json['weekly_predictions'].map((x) => WeeklyPrediction.fromJson(x))),
      climateMetrics: ClimateMetrics.fromJson(json['climate_metrics']),
    );
  }
}

class WeeklyPrediction {
  final int week;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? adjustedClose; // Nullable for non-climate predictions
  final String? climateAdjustment;
  final double? temperatureStress;
  final double? rainfallStress;

  WeeklyPrediction({
    required this.week,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.adjustedClose,
    this.climateAdjustment,
    this.temperatureStress,
    this.rainfallStress,
  });

  factory WeeklyPrediction.fromJson(Map<String, dynamic> json) {
    return WeeklyPrediction(
      week: json['week'],
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      adjustedClose: json['adjusted_close'] != null
          ? (json['adjusted_close'] as num).toDouble()
          : null,
      climateAdjustment: json['climate_adjustment'],
      temperatureStress: json['temperature_stress'] != null
          ? (json['temperature_stress'] as num).toDouble()
          : null,
      rainfallStress: json['rainfall_stress'] != null
          ? (json['rainfall_stress'] as num).toDouble()
          : null,
    );
  }
}

class ClimateMetrics {
  final double averageTempC;
  final bool growingSeason;
  final double rainfallAnomalyMm;
  final double stressScore;

  ClimateMetrics({
    required this.averageTempC,
    required this.growingSeason,
    required this.rainfallAnomalyMm,
    required this.stressScore,
  });

  factory ClimateMetrics.fromJson(Map<String, dynamic> json) {
    return ClimateMetrics(
      averageTempC: (json['average_temp_c'] as num).toDouble(),
      growingSeason: json['growing_season'],
      rainfallAnomalyMm: (json['rainfall_anomaly_mm'] as num).toDouble(),
      stressScore: (json['stress_score'] as num).toDouble(),
    );
  }
}
