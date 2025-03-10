class RealTimePrediction {
  final String symbol;
  final double predictedClose;
  final String timestamp;

  RealTimePrediction({required this.symbol, required this.predictedClose, required this.timestamp});

  factory RealTimePrediction.fromJson(Map<String, dynamic> json) {
    return RealTimePrediction(
      symbol: json['symbol'],
      predictedClose: json['predicted_close'].toDouble(),
      timestamp: json['timestamp'],
    );
  }
}

class RealTimePredictionResponse {
  final bool success;
  final RealTimePrediction data;

  RealTimePredictionResponse({required this.success, required this.data});

  factory RealTimePredictionResponse.fromJson(Map<String, dynamic> json) {
    return RealTimePredictionResponse(
      success: json['success'],
      data: RealTimePrediction.fromJson(json['data']),
    );
  }
}



class HistoricalPrediction {
  final String date;
  final double predictedClose;
  final double actualClose;

  HistoricalPrediction({required this.date, required this.predictedClose, required this.actualClose});

  factory HistoricalPrediction.fromJson(Map<String, dynamic> json) {
    return HistoricalPrediction(
      date: json['date'],
      predictedClose: json['predicted_close'].toDouble(),
      actualClose: json['actual_close'].toDouble(),
    );
  }
}

class HistoricalPredictionsResponse {
  final bool success;
  final String symbol;
  final List<HistoricalPrediction> historicalPredictions;

  HistoricalPredictionsResponse({required this.success, required this.symbol, required this.historicalPredictions});

  factory HistoricalPredictionsResponse.fromJson(Map<String, dynamic> json) {
    return HistoricalPredictionsResponse(
      success: json['success'],
      symbol: json['data']['symbol'],
      historicalPredictions: List<HistoricalPrediction>.from(
        json['data']['historical_predictions'].map((x) => HistoricalPrediction.fromJson(x)),
      ),
    );
  }
}


class FuturePrediction {
  final int week;
  final double predictedClose;

  FuturePrediction({required this.week, required this.predictedClose});

  factory FuturePrediction.fromJson(Map<String, dynamic> json) {
    return FuturePrediction(
      week: json['week'],
      predictedClose: json['predicted_close'].toDouble(),
    );
  }
}

class FuturePredictionsResponse {
  final bool success;
  final String symbol;
  final List<FuturePrediction> futurePredictions;

  FuturePredictionsResponse({required this.success, required this.symbol, required this.futurePredictions});

  factory FuturePredictionsResponse.fromJson(Map<String, dynamic> json) {
    return FuturePredictionsResponse(
      success: json['success'],
      symbol: json['data']['symbol'],
      futurePredictions: List<FuturePrediction>.from(
        json['data']['future_predictions'].map((x) => FuturePrediction.fromJson(x)),
      ),
    );
  }




  
}

class Prediction {
  final String symbol;
  final double predictedClose;
  final String timestamp;

  Prediction({
    required this.symbol,
    required this.predictedClose,
    required this.timestamp,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      symbol: json['symbol'],
      predictedClose: json['predicted_close'].toDouble(),
      timestamp: json['timestamp'],
    );
  }
}




class PredictionWithClimate {
  final String symbol;
  final double predictedClose;
  final String timestamp;
  final Map<String, dynamic> climateData;

  PredictionWithClimate({
    required this.symbol,
    required this.predictedClose,
    required this.timestamp,
    required this.climateData,
  });

  factory PredictionWithClimate.fromJson(Map<String, dynamic> json) {
    return PredictionWithClimate(
      symbol: json['symbol'],
      predictedClose: json['predicted_close'].toDouble(),
      timestamp: json['timestamp'],
      climateData: json['climate_data'],
    );
  }




  
}



 