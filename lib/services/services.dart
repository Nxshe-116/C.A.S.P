import 'dart:async';
import 'dart:convert';
import 'package:admin/models/climate.dart';
import 'package:admin/models/company.dart';
import 'package:admin/models/notifications.dart';
import 'package:admin/models/predictions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const String baseUrl = 'https://casp-z2u5.onrender.com';
  static const Duration timeoutDuration = Duration(seconds: 15);

  Future<List<Company>> fetchCompanies() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/companies/'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Company.fromJson(json)).toList();
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load companies: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching companies: $e');
      rethrow;
    }
  }

  Future<Company> fetchCompanyDetails(String symbol) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/companies/$symbol'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return Company.fromJson(jsonResponse['data']);
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load company details: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching company details: $e');
      rethrow;
    }
  }

  // PREDICTION ENDPOINTS
  Future<RealTimePrediction?> fetchRealTimePrediction(String symbol) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/model/real-time/$symbol'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return RealTimePrediction.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching real-time prediction: $e');
      return null;
    }
  }

  Future<RealTimePrediction?> fetchRealTimeWithClimate(String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/real-time-with-climate/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return RealTimePrediction.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching real-time with climate: $e');
      return null;
    }
  }

  Future<AgriculturalPrediction> fetchAgriculturalPrediction(
      String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/agri-prediction/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return AgriculturalPrediction.fromJson(jsonResponse['data']);
        }
        throw Exception(jsonResponse['error'] ?? 'API returned invalid data');
      }
      throw Exception('Failed to load prediction: ${response.statusCode}');
    } on http.ClientException catch (e) {
      debugPrint('Network error: $e');
      return _createErrorPrediction(symbol, 'Network error: $e');
    } on TimeoutException catch (e) {
      debugPrint('Request timeout: $e');
      return _createErrorPrediction(symbol, 'Request timed out');
    } on FormatException catch (e) {
      debugPrint('JSON format error: $e');
      return _createErrorPrediction(symbol, 'Invalid data format');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return _createErrorPrediction(symbol, 'Unexpected error: $e');
    }
  }

  AgriculturalPrediction _createErrorPrediction(String symbol, String error) {
    return AgriculturalPrediction(
      symbol: symbol,
      currentPrediction: 0.0,
      basePrice: 0.0,
      climateAdjustment: '0%',
      climateReport: ClimateReport(
        impactStatement: 'Error loading prediction',
        detailedAnalysis: error,
        recommendations: ['Please try again later'],
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
      recommendations: ['Check your connection'],
    );
  }

  Future<PredictionWithClimate?> fetchPredictionWithClimate(
      String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/with-climate/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return PredictionWithClimate.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching with-climate prediction: $e');
      return null;
    }
  }

  Future<Prediction?> fetchPredictionWithoutClimate(String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/without-climate/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return Prediction.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching without-climate prediction: $e');
      return null;
    }
  }

  Future<List<HistoricalPrediction>> fetchHistoricalPredictions(
      String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/history/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data =
              jsonResponse['data']['historical_predictions'];
          return data
              .map((json) => HistoricalPrediction.fromJson(json))
              .toList();
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load history: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching historical predictions: $e');
      rethrow;
    }
  }

  Future<List<WeeklyPrediction>> fetchWeeklyPredictions(String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/with-climate/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data']['weekly_predictions'];
          return data.map((json) => WeeklyPrediction.fromJson(json)).toList();
        }
        throw Exception('API returned success: false');
      }
      throw Exception(
          'Failed to load weekly predictions: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching weekly predictions: $e');
      rethrow;
    }
  }

  // CLIMATE ENDPOINTS
  Future<ClimateData> fetchClimateData(int year, String month) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/climate/$year/$month'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return ClimateData.fromJson(jsonResponse['data']);
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load climate data: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching climate data: $e');
      rethrow;
    }
  }

  Future<ClimateMetrics> fetchClimateMetrics(String symbol) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/model/with-climate/$symbol'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return ClimateMetrics.fromJson(
              jsonResponse['data']['climate_metrics']);
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load climate metrics: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching climate metrics: $e');
      rethrow;
    }
  }

  // FIREBASE METHODS
  Future<bool> doesCompanyExistInDatabase(String companyName) async {
    try {
      final querySnapshot = await firestore
          .collection('companies')
          .where('name', isEqualTo: companyName)
          .get()
          .timeout(timeoutDuration);
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking company existence: $e');
      rethrow;
    }
  }

  String generateCompanyId(String companyName) {
    final prefix = companyName.length >= 3
        ? companyName.substring(0, 3).toLowerCase()
        : companyName.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}$timestamp';
  }

  Future<void> addCompaniesToUser(String uid, List<Company> companies) async {
    try {
      final userDoc = await firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(timeoutDuration);
      final userData = userDoc.data();
      final List<dynamic> selectedCompanies =
          userData?['selectedCompanies'] ?? [];

      for (var company in companies) {
        final companyExists = selectedCompanies.any(
            (selectedCompany) => selectedCompany['symbol'] == company.symbol);

        if (!companyExists) {
          final companyRef =
              firestore.collection('companies').doc(company.symbol);
          final companyDoc = await companyRef.get();

          if (!companyDoc.exists) {
            await companyRef.set(company.toJson());
          }

          await firestore.collection('users').doc(uid).update({
            'selectedCompanies': FieldValue.arrayUnion([company.toJson()]),
          });
        }
      }
    } catch (e) {
      debugPrint('Error adding companies to user: $e');
      rethrow;
    }
  }

  Future<void> addNotificationToUser(
      String uid, Notifications notification) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notification.notifId)
          .set(notification.toMap())
          .timeout(timeoutDuration);
    } catch (e) {
      debugPrint('Error adding notification: $e');
      rethrow;
    }
  }
}
