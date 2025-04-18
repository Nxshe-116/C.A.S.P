// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'package:admin/models/predictions.dart';
import 'package:admin/models/tickers.dart';
import 'package:admin/screens/dashboard/components/date_formatter.dart';
import 'package:admin/services/services.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants.dart';

class StockInfoCard extends StatefulWidget {
  final String userId;

  const StockInfoCard({Key? key, required this.userId}) : super(key: key);

  @override
  State<StockInfoCard> createState() => _StockInfoCardState();
}

class _StockInfoCardState extends State<StockInfoCard> {
  final ApiService apiService = ApiService();
  List<String> watchlist = [];
  String? selectedCompany;
  AgriculturalPrediction? currentPrediction;
  bool isLoading = false;
  String? errorMessage;
  int _retryCount = 0;
  final int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchSelectedCompanies();
    } catch (e) {
      _handleError('Failed to initialize data', e);
    }
  }

  Future<void> _fetchSelectedCompanies() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!mounted) return;

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final companies = (userData['selectedCompanies'] as List<dynamic>?)
              ?.map<String>((c) => c is Map ? c['name']?.toString() ?? '' : '')
              .where((name) => name.isNotEmpty)
              .toList() ??
          [];

      if (companies.isEmpty) {
        throw Exception('No companies in watchlist');
      }

      setState(() {
        watchlist = companies;
        selectedCompany = companies.first;
      });

      await _fetchCompanyPredictionWithRetry(selectedCompany!);
    } catch (e) {
      _handleError('Failed to load watchlist', e);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _fetchCompanyPredictionWithRetry(String symbol) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      _retryCount = 0;
    });
    await _fetchCompanyPrediction(symbol);
  }

  Future<void> _fetchCompanyPrediction(String symbol) async {
    try {
      final response = await apiService.fetchAgriculturalPrediction(symbol);

      if (response == null) {
        throw Exception('Received null prediction response');
      }

      if (!mounted) return;

      setState(() {
        currentPrediction = response;
        errorMessage = null;
      });
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: 1));
        await _fetchCompanyPrediction(symbol);
      } else {
        _handleError('Failed to load prediction for $symbol', e);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleError(String contextMessage, dynamic error) {
    final message = error
        .toString()
        .replaceAll('Unexpected null value', 'Missing required data');

    if (!mounted) return;

    setState(() {
      errorMessage = message;
      currentPrediction = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$contextMessage: $message'),
        backgroundColor: Colors.red,
      ),
    );

    debugPrint('Error: $contextMessage - $error');
  }

  void _handleRefresh() {
    if (selectedCompany != null) {
      _fetchCompanyPredictionWithRetry(selectedCompany!);
    } else {
      _initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompanyDropdown(),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _handleRefresh,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        fillColor: Color.fromARGB(255, 223, 223, 223),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedCompany,
          hint: Text('Select company'),
          items: watchlist.map((company) {
            return DropdownMenuItem<String>(
              value: company,
              child: Text(company),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _fetchCompanyPredictionWithRetry(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }
    if (errorMessage != null) {
      return _buildErrorState();
    }
    if (currentPrediction != null) {
      return buildPredictionDetails(currentPrediction!, context);
    }
    if (watchlist.isEmpty) {
      return _buildEmptyState();
    }
    return _buildNoDataState();
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          CircularProgressIndicator(),
          if (_retryCount > 0)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Retrying... ($_retryCount/$_maxRetries)',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 8),
          Text(
            errorMessage ?? 'An error occurred',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 40),
          SizedBox(height: 8),
          Text('No companies in your watchlist'),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 40),
          SizedBox(height: 8),
          Text('No prediction data available'),
        ],
      ),
    );
  }
}

Widget buildErrorCard(String message) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red),
          Text(message),
        ],
      ),
    ),
  );
}

Widget buildPredictionDetails(
  AgriculturalPrediction prediction,
  BuildContext context,
) {
  Object safeToStringFixed(dynamic value, [int fractionDigits = 2]) {
    if (value == null) return 'N/A';
    if (value is num) return value.toStringAsFixed(fractionDigits);
    if (prediction == null || prediction.symbol == null) {
      return buildErrorCard('Invalid prediction data');
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toStringAsFixed(fractionDigits) ?? 'N/A';
    }
    return 'N/A';
  }

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
            buildInfoRow('Symbol', generateTicker(prediction.symbol)),
            if (isErrorState)
              Text(
                'Error loading prediction data',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              buildInfoRow(
                'Current Prediction',
                'ZiG ${safeToStringFixed(prediction.currentPrediction)}',
                valueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              buildInfoRow(
                'Base Price',
                'ZiG ${safeToStringFixed(prediction.basePrice)}',
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
              buildClimateFactorSection(
                context,
                title: 'Temperature',
                value:
                    '${safeToStringFixed(prediction.stressFactors.temperature.value)}°C',
                score: prediction.stressFactors.temperature.stressScore,
                range: prediction.stressFactors.temperature.optimalRange,
              ),
              Divider(height: 20, thickness: 1),
              buildClimateFactorSection(
                context,
                title: 'Rainfall',
                value:
                    '${safeToStringFixed(prediction.stressFactors.rainfall.value)}mm',
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
Widget buildClimateFactorSection(
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
          color: getStressColor(score),
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

Color getStressColor(double score) {
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
                  child: Text(
                    company,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w200),
                  ),
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
