// ignore_for_file: deprecated_member_use

import 'package:admin/models/predictions.dart';
import 'package:admin/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class StockInfoCard extends StatefulWidget {
  final String userId;

  const StockInfoCard({
    Key? key,
    required this.userId, // Updated parameter
  }) : super(key: key);

  @override
  State<StockInfoCard> createState() => _StockInfoCardState();
}

class _StockInfoCardState extends State<StockInfoCard> {
  final ApiService apiService = ApiService();
  List<String> watchlist = [];
  String? selectedCompany;
  AgriculturalPrediction? currentPrediction;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //  predictionsFuture = Future.value({}); // Initialize with an empty Future
    fetchSelectedCompanies();
  }

  Future<void> fetchSelectedCompanies() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final companies = (userData?['selectedCompanies'] as List<dynamic>?)
                ?.map((c) => c['name'] as String)
                .toList() ??
            [];

        if (mounted) {
          setState(() => watchlist = companies);
          if (companies.isNotEmpty) {
            await fetchCompanyPrediction(companies.first);
          }
        }
      } else {
        print('User document not found.');
      }
    } catch (e) {
      print('Error fetching selected companies: $e');
    }
  }

  Future<void> fetchCompanyPrediction(String symbol) async {
    setState(() {
      isLoading = true;
      selectedCompany = symbol;
    });

    try {
      final prediction = await apiService.fetchAgriculturalPrediction(symbol);
      if (mounted) {
        setState(() => currentPrediction = prediction);
      }
    } catch (e) {
      print('Error fetching prediction: $e');
      if (mounted) {
        setState(() => currentPrediction = null);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Renamed
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        // border: Border.all(width: 2, color: const Color(0xFFF4FAFF)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Column(
        children: [
          SearchField(
            companies: watchlist,
            selectedCompany: selectedCompany,
            onChanged: (symbol) {
              if (symbol != null) fetchCompanyPrediction(symbol);
            },
          ),
          SizedBox(height: defaultPadding),
          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding),
              child: CircularProgressIndicator(),
            )
          else if (currentPrediction != null)
            buildPredictionDetails(currentPrediction!, context)
          else if (selectedCompany != null)
            Text('No prediction data available'),
        ],
      ),
    );
  }
}

Widget buildPredictionDetails(
  AgriculturalPrediction prediction,
  BuildContext context,
) {
  final tempFactors = prediction.stressFactors['temperature'];
  final rainFactors = prediction.stressFactors['rainfall'];

  return Column(
    children: [
      // Price Information
      buildInfoCard(
        context: context,
        title: 'Price Analysis',
        children: [
          buildInfoRow('Current Prediction',
              'ZiG ${prediction.currentPrediction.toStringAsFixed(2)}'),
          buildInfoRow(
              'Base Price', 'ZiG ${prediction.basePrice.toStringAsFixed(2)}'),
          buildInfoRow('Climate Adjustment', prediction.climateAdjustment),
        ],
      ),

      SizedBox(height: defaultPadding),

      // Climate Stress Factors
      buildInfoCard(
        context: context,
        title: 'Climate Stress Factors',
        children: [
          buildInfoRow('Temperature', '${tempFactors['value']}°C'),
          buildInfoRow(
              'Stress Score', tempFactors['stress_score'].toStringAsFixed(4)),
          buildInfoRow('Optimal Range',
              '${tempFactors['optimal_range'][0]}°C - ${tempFactors['optimal_range'][1]}°C'),
          Divider(),
          buildInfoRow('Rainfall', '${rainFactors['value']}mm'),
          buildInfoRow(
              'Stress Score', rainFactors['stress_score'].toStringAsFixed(4)),
          buildInfoRow(
              'Critical Threshold', '${rainFactors['critical_threshold']}mm'),
        ],
      ),

      SizedBox(height: defaultPadding),

      // Climate Report
      buildInfoCard(
        title: 'Climate Report',
        children: [
          Text(prediction.climateReport as String,
              style: TextStyle(fontSize: 14)),
        ],
        context: context,
      ),
    ],
  );
}

Widget buildInfoCard({
  required String title,
  required List<Widget> children,
  required BuildContext context,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
          ),
          SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}

Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class SearchField extends StatefulWidget {
  final List<String> companies;
  final String? selectedCompany;
  final ValueChanged<String?> onChanged;

  const SearchField({
    Key? key,
    required this.companies,
    this.selectedCompany,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: InputDecorator(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true, // Reduces internal padding
              iconSize: 20, // Smaller dropdown icon
              value: widget.selectedCompany,
              isExpanded: true,
              hint: Text('Select a company'),
              items: widget.companies.map((String company) {
                return DropdownMenuItem<String>(
                  value: company,
                  child: Text(company),
                );
              }).toList(),
              onChanged: widget.onChanged,
              dropdownColor: Colors.white,
            ),
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Reduced padding

            hintText: "Search",
            fillColor: Color.fromARGB(255, 223, 223, 223),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          )),
    );
  }
}
