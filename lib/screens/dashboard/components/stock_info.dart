// ignore_for_file: deprecated_member_use

import 'package:admin/models/predictions.dart';
import 'package:admin/screens/dashboard/components/date_formatter.dart';
import 'package:admin/services/services.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    if (!mounted) return;

    setState(() {
      isLoading = true;
      selectedCompany = symbol;
      currentPrediction = null; // Clear previous prediction
    });

    try {
      final response = await apiService.fetchAgriculturalPrediction(symbol);
      if (!mounted) return;

      setState(() {
        currentPrediction = response;
      });
    } catch (e, stackTrace) {
      print('Error fetching prediction for $symbol: $e');
      print(stackTrace);
      if (!mounted) return;

      setState(() {
        currentPrediction = null;
      });

      // Show error to user if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load prediction for $symbol'),
          duration: const Duration(seconds: 3),
        ),
      );
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
  // Show error state if prediction indicates an error
  final isErrorState = prediction.symbol == 'ERROR';

  final pages = [
    // Price Information Card
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: 90.w, maxWidth: 100.w, minHeight: 300, maxHeight: 300),
        child: buildInfoCard(
          context: context,
          title: isErrorState ? 'Error' : 'Price Analysis',
          children: [
            buildInfoRow('Symbol', prediction.symbol),
            if (isErrorState)
              Text(
                'Error loading prediction data',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              buildInfoRow(
                'Current Prediction',
                'ZiG ${prediction.currentPrediction.toStringAsFixed(2)}',
                valueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              buildInfoRow(
                'Base Price',
                'ZiG ${prediction.basePrice.toStringAsFixed(2)}',
              ),
              buildInfoRow(
                'Climate Adjustment',
                prediction.climateAdjustment,
                valueStyle: TextStyle(
                  color: prediction.climateAdjustment.startsWith('-')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              buildInfoRow(
                'Last Updated',
                TimeUtils.timeAgo(prediction.timestamp),
              ),
            ],
          ],
        ),
      ),
    ),

    // Only show other cards if not in error state
    if (!isErrorState) ...[
      // Climate Stress Factors Card
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 280, maxWidth: 300),
          child: buildInfoCard(
            context: context,
            title: 'Climate Stress Factors',
            children: [
              _buildClimateFactorSection(
                context,
                title: 'Temperature',
                value:
                    '${prediction.stressFactors.temperature.value?.toStringAsFixed(2) ?? 'N/A'}°C',
                score: prediction.stressFactors.temperature.stressScore,
                range: prediction.stressFactors.temperature.optimalRange,
              ),
              Divider(height: 20, thickness: 1),
              _buildClimateFactorSection(
                context,
                title: 'Rainfall',
                value:
                    '${prediction.stressFactors.rainfall.value?.toStringAsFixed(2) ?? 'N/A'}mm',
                score: prediction.stressFactors.rainfall.stressScore,
                threshold: prediction.stressFactors.rainfall.criticalThreshold,
              ),
            ],
          ),
        ),
      ),

      // Climate Report Card
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 280, maxWidth: 320),
          child: buildInfoCard(
            context: context,
            title: 'Climate Impact Report',
            children: [
              Text(
                prediction.climateReport.impactStatement,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isErrorState ? Colors.red : null,
                ),
              ),
              SizedBox(height: 8),
              Text(prediction.climateReport.detailedAnalysis),
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...prediction.climateReport.recommendations.map(
                    (recommendation) => Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(recommendation)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ];

  return Column(
    children: [
      SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Swiper(
          allowImplicitScrolling: false,
          itemBuilder: (BuildContext context, int index) {
            return pages[index];
          },
          itemCount: pages.length,
          viewportFraction: 01.2,
          scale: 0.9,
          pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              color: Colors.grey,
              activeColor: primaryColor,
            ),
          ),
        ),
      ),
    ],
  );
}

// Helper widget for climate factor sections
Widget _buildClimateFactorSection(
  BuildContext context, {
  required String title,
  required String value,
  required double score,
  List<dynamic>? range,
  dynamic threshold,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      SizedBox(height: 8),
      buildInfoRow('Current', value),
      buildInfoRow(
        'Stress Score',
        score.toStringAsFixed(4),
        valueStyle: TextStyle(
          color: _getStressColor(score),
        ),
      ),
      if (range != null && range.length >= 2)
        buildInfoRow(
          'Optimal Range',
          '${range[0]}°C - ${range[1]}°C',
        ),
      if (threshold != null)
        buildInfoRow(
          'Critical Threshold',
          '$threshold${title == 'Temperature' ? '°C' : 'mm'}',
        ),
    ],
  );
}

Color _getStressColor(double score) {
  if (score > 0.2) return Colors.red;
  if (score > 0.1) return Colors.orange;
  return Colors.green;
}

Widget buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}

Card buildInfoCard({
  required BuildContext context,
  required String title,
  required List<Widget> children,
}) {
  return Card(
    color: Colors.transparent,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Divider(height: 20, thickness: 1),
          Expanded(
            // Add this
            child: SingleChildScrollView(
              // Also consider adding this for scrollable content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
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
