import 'dart:convert';
import 'package:admin/models/company.dart';
import 'package:admin/models/predictions.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://casp-z2u5.onrender.com'; // Ensure this URL is correct

  // Fetch all companies
  Future<List<Company>> fetchCompanies() async {
    final response = await http.get(Uri.parse('$baseUrl/api/companies/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load companies');
    }
  }

  // Fetch details for a specific company
  Future<Company> fetchCompanyDetails(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/companies/$symbol'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return Company.fromJson(data);
    } else {
      throw Exception('Failed to load company details');
    }
  }

  // Fetch real-time prediction for a company
  Future<RealTimePrediction> fetchRealTimePrediction(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/real-time/$symbol'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return RealTimePrediction.fromJson(data);
    } else {
      throw Exception('Failed to load real-time prediction');
    }
  }

  // Fetch prediction without climate data for a company
  Future<Prediction> fetchPredictionWithoutClimate(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/without-climate/$symbol'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return Prediction.fromJson(data);
    } else {
      throw Exception('Failed to load prediction without climate data');
    }
  }

  // Fetch prediction with climate data for a company
  Future<PredictionWithClimate> fetchPredictionWithClimate(
      String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/with-climate/$symbol'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return PredictionWithClimate.fromJson(data);
    } else {
      throw Exception('Failed to load prediction with climate data');
    }
  }

  // Fetch historical predictions for a company
  Future<List<HistoricalPrediction>> fetchHistoricalPredictions(
      String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/history/$symbol'));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body)['data']['historical_predictions'];
      return data.map((json) => HistoricalPrediction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load historical predictions');
    }
  }

  // Fetch future predictions for a company
  Future<List<FuturePrediction>> fetchFuturePredictions(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/future/$symbol'));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body)['data']['future_predictions'];
      return data.map((json) => FuturePrediction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load future predictions');
    }
  }
}
