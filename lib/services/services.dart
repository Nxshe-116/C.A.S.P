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

  // Existing company methods...
  Future<List<Company>> fetchCompanies() async {
    final response = await http.get(Uri.parse('$baseUrl/api/companies/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load companies');
    }
  }

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

  // PREDICTION ENDPOINTS
  Future<RealTimePrediction?> fetchRealTimePrediction(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/real-time/$symbol'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return RealTimePrediction.fromJson(jsonResponse['data']);
      }
    }
    return null;
  }

  Future<RealTimePrediction?> fetchRealTimeWithClimate(String symbol) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/model/real-time-with-climate/$symbol'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return RealTimePrediction.fromJson(jsonResponse['data']);
      }
    }
    return null;
  }

  Future<AgriculturalPrediction> fetchAgriculturalPrediction(
      String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/agri-prediction/$symbol'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return AgriculturalPrediction.fromJson(data);
    } else {
      throw Exception('Failed to load agricultural prediction');
    }
  }

  Future<PredictionWithClimate?> fetchPredictionWithClimate(
      String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/model/with-climate/$symbol'),
      );

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
      final response = await http.get(
        Uri.parse('$baseUrl/api/model/without-climate/$symbol'),
      );

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

  Future<List<WeeklyPrediction>> fetchWeeklyPredictions(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/with-climate/$symbol'));
    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body)['data']['weekly_predictions'];
      return data.map((json) => WeeklyPrediction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load weekly predictions');
    }
  }

  // CLIMATE ENDPOINTS
  Future<ClimateData> fetchClimateData(int year, String month) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/climate/$year/$month'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return ClimateData.fromJson(data);
    } else {
      throw Exception('Failed to load climate data');
    }
  }

  Future<ClimateMetrics> fetchClimateMetrics(String symbol) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/model/with-climate/$symbol'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body)['data']['climate_metrics'];
      return ClimateMetrics.fromJson(data);
    } else {
      throw Exception('Failed to load climate metrics');
    }
  }

  // FIREBASE METHODS
  Future<bool> doesCompanyExistInDatabase(String companyName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .where('name', isEqualTo: companyName)
        .get();
    return querySnapshot.docs.isNotEmpty;
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
      final userDoc = await firestore.collection('users').doc(uid).get();
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
          selectedCompanies.add(company.toJson());
        }
      }
    } catch (e) {
      throw Exception('Failed to add companies to user: $e');
    }
  }

  Future<void> addNotificationToUser(
      String uid, Notifications notification) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notification.notifId)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }
}
