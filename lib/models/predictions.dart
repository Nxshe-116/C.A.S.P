class RealTimePrediction {
  final double currentPrediction;
  final double previousPrediction;
  final String symbol;
  final DateTime timestamp;

  RealTimePrediction({
    required this.currentPrediction,
    required this.previousPrediction,
    required this.symbol,
    required this.timestamp,
  });

  factory RealTimePrediction.fromJson(Map<String, dynamic> json) {
    return RealTimePrediction(
      currentPrediction: (json['current_prediction'] as num).toDouble(),
      previousPrediction: (json['previous_prediction'] as num).toDouble(),
      symbol: json['symbol'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
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

class AgriculturalPrediction {
  final String symbol;
  final double currentPrediction;
  final double basePrice;
  final String climateAdjustment;
  final ClimateReport climateReport;
  final ClimateStressFactors stressFactors;
  final DateTime timestamp;

  AgriculturalPrediction({
    required this.symbol,
    required this.currentPrediction,
    required this.basePrice,
    required this.climateAdjustment,
    required this.climateReport,
    required this.stressFactors,
    required this.timestamp,
    required List<String> recommendations,
  });

  factory AgriculturalPrediction.fromJson(Map<String, dynamic> json) {
    try {
      return AgriculturalPrediction(
        symbol: json['symbol'] as String? ?? 'N/A',
        currentPrediction:
            (json['current_prediction'] as num?)?.toDouble() ?? 0.0,
        basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
        climateAdjustment: json['climate_adjustment'] as String? ?? '0%',
        climateReport: ClimateReport.fromJson(
          json['climate_report'] as Map<String, dynamic>? ?? {},
        ),
        stressFactors: ClimateStressFactors.fromJson(
          json['stress_factors'] as Map<String, dynamic>? ?? {},
        ),
        timestamp: DateTime.parse(
            json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
        recommendations: [],
      );
    } catch (e, stackTrace) {
      print('Error parsing AgriculturalPrediction: $e');
      print(stackTrace);
      return AgriculturalPrediction(
        symbol: 'ERROR',
        currentPrediction: 0.0,
        basePrice: 0.0,
        climateAdjustment: '0%',
        climateReport: ClimateReport(
          impactStatement: 'Error loading climate report',
          detailedAnalysis: 'Failed to parse prediction data',
          recommendations: ['Check API connection'],
        ),
        stressFactors: ClimateStressFactors(
          temperature: ClimateFactor(
            value: 'N/A',
            stressScore: 0.0,
            optimalRange: [],
          ),
          rainfall: ClimateFactor(
            value: 'N/A',
            stressScore: 0.0,
            optimalRange: [],
          ),
        ),
        timestamp: DateTime.now(),
        recommendations: [],
      );
    }
  }
}

class ClimateStressFactors {
  final ClimateFactor temperature;
  final ClimateFactor rainfall;

  ClimateStressFactors({
    required this.temperature,
    required this.rainfall,
  });

  factory ClimateStressFactors.fromJson(Map<String, dynamic> json) {
    return ClimateStressFactors(
      temperature: ClimateFactor.fromJson(
        json['temperature'] as Map<String, dynamic>? ?? {},
      ),
      rainfall: ClimateFactor.fromJson(
        json['rainfall'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ClimateFactor {
  final dynamic value;
  final double stressScore;
  final List<dynamic> optimalRange;
  final dynamic criticalThreshold;

  ClimateFactor({
    required this.value,
    required this.stressScore,
    required this.optimalRange,
    this.criticalThreshold,
  });

  factory ClimateFactor.fromJson(Map<String, dynamic> json) {
    return ClimateFactor(
      value: json['value'] ?? 'N/A',
      stressScore: (json['stress_score'] as num?)?.toDouble() ?? 0.0,
      optimalRange: json['optimal_range'] is List
          ? json['optimal_range'] as List<dynamic>
          : [],
      criticalThreshold: json['critical_threshold'],
    );
  }
}

class ClimateReport {
  final String impactStatement;
  final String detailedAnalysis;
  final List<String> recommendations;

  ClimateReport({
    required this.impactStatement,
    required this.detailedAnalysis,
    required this.recommendations,
  });

  factory ClimateReport.fromJson(Map<String, dynamic> json) {
    // Filter out null values from recommendations
    final rawRecommendations = json['recommendations'] as List<dynamic>? ?? [];
    final validRecommendations = rawRecommendations
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList();

    return ClimateReport(
      impactStatement:
          json['impact_statement'] as String? ?? 'No impact statement',
      detailedAnalysis:
          json['detailed_analysis'] as String? ?? 'No detailed analysis',
      recommendations: validRecommendations.isNotEmpty
          ? validRecommendations
          : ['No recommendations provided'],
    );
  }
}

class HistoricalPredictionModel {
  final String symbol;
  final List<PredictionEntry>
      historicalPredictions; // Changed from historicalData
  final String? note;
  final bool success;

  HistoricalPredictionModel({
    required this.symbol,
    required this.historicalPredictions,
    this.note,
    required this.success,
  });

factory HistoricalPredictionModel.fromJson(Map<String, dynamic> json) {
  return HistoricalPredictionModel(
    symbol: json['data']['symbol'],
    historicalPredictions: (json['data']['historical_data'] as List)
        .map((item) => PredictionEntry.fromJson(item))
        .toList(),
    note: json['data']['note'],
    success: json['success'], // This comes from the root, not data
  );
}
}

class PredictionEntry {
  final double actualClose; // Changed from actualPrice
  final String date;
  final String direction;
  final double predictedClose; // Changed from predictedPrice
  final double variancePercent;

  PredictionEntry({
    required this.actualClose,
    required this.date,
    required this.direction,
    required this.predictedClose,
    required this.variancePercent,
  });

  factory PredictionEntry.fromJson(Map<String, dynamic> json) {
    return PredictionEntry(
      actualClose: json['actual_price']?.toDouble() ?? 0.0,
      date: json['date'],
      direction: json['direction'],
      predictedClose: json['predicted_price']?.toDouble() ?? 0.0,
      variancePercent: json['variance_percent']?.toDouble() ?? 0.0,
    );
  }

  // For backward compatibility
  double get actualPrice => actualClose;
  double get predictedPrice => predictedClose;
}

class PredictionEntryNorm {
  final String date;
  final double predictedClose;
  final double actualClose;

  PredictionEntryNorm({
    required this.date,
    required this.predictedClose,
    required this.actualClose,
  });

  factory PredictionEntryNorm.fromJson(Map<String, dynamic> json) {
    return PredictionEntryNorm(
      date: json['date'],
      predictedClose: (json['predicted_close'] as num).toDouble(),
      actualClose: (json['actual_close'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'predicted_close': predictedClose,
      'actual_close': actualClose,
    };
  }
}
