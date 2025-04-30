class ClimateMetrics {
  final double? rainfallMm;
  final double? tempC;
  final bool? growingSeason;

  ClimateMetrics({
    this.rainfallMm,
    this.tempC,
    this.growingSeason,
  });

  factory ClimateMetrics.fromJson(Map<String, dynamic> json) {
    return ClimateMetrics(
      rainfallMm: json['rainfall_mm']?.toDouble(),
      tempC: json['temp_c']?.toDouble(),
      growingSeason: json['growing_season'],
    );
  }
}
