// ignore_for_file: unnecessary_null_comparison

import 'package:admin/constants.dart';
import 'package:admin/models/tickers.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:admin/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:shimmer/shimmer.dart';

class PortfolioScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final String uid;

  PortfolioScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
  }) : super(key: key);

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<StockValidation> stocks = [];
  String? expandedStock;
  bool isLoading = true;
  String? errorMessage;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await fetchSelectedCompanies();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
      });
    }
  }

  Future<void> fetchSelectedCompanies() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final List<dynamic> selectedCompanies =
            userData?['selectedCompanies'] ?? [];

        // Extract tickers for real-time data fetching
        final List<String> tickers = selectedCompanies
            .map((company) => company['symbol'] as String)
            .toList();

        // First create stock items with basic info
        List<StockValidation> tempStocks = selectedCompanies.map((company) {
          return StockValidation(
            symbol: company['symbol'] as String,
            name: company['name'] as String,
            currentPrediction: 0, // Will be updated from real-time data
            actualPrice: null,
            mse: 0, // Will be updated from real-time data if available
            rmse: 0, // Will be updated from real-time data if available
            mle: 0, // Will be updated when we have actual prices
            ksStatistic: 0, // Will be updated when we have actual prices
          );
        }).toList();

        setState(() {
          stocks = tempStocks;
        });

        // Now fetch real-time data for each ticker
        await fetchRealTimeData(tickers);
      } else {
        setState(() {
          errorMessage = 'User document not found.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching selected companies: $e';
      });
    }
  }

  Future<void> fetchRealTimeData(List<String> tickers) async {
    try {
      for (final ticker in tickers) {
        final realTimePrediction =
            await apiService.fetchRealTimePrediction(ticker);

        if (realTimePrediction != null) {
          setState(() {
            final index = stocks.indexWhere((s) => s.symbol == ticker);
            if (index != -1) {
              stocks[index] = stocks[index].copyWith(
                currentPrediction: realTimePrediction.currentPrediction,
                previousPrediction: realTimePrediction.previousPrediction,
              );
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching real-time data: $e';
      });
    }
  }

  // Calculate Root Mean Square Error (RMSE)
  double calculateRMSE(List<double> predictions, List<double> actuals) {
    if (predictions.length != actuals.length || predictions.isEmpty) {
      return 0;
    }

    double sum = 0;
    for (int i = 0; i < predictions.length; i++) {
      sum += math.pow(predictions[i] - actuals[i], 2);
    }
    return math.sqrt(sum / predictions.length);
  }

  // Calculate Maximum Likelihood Estimation (MLE) assuming normal distribution
  double calculateMLE(List<double> errors) {
    if (errors.isEmpty) return 0;

    final n = errors.length;
    final variance = errors.map((e) => e * e).reduce((a, b) => a + b) / n;

    // Log likelihood for normal distribution
    return -n / 2 * math.log(2 * math.pi * variance) -
        (1 / (2 * variance)) * errors.map((e) => e * e).reduce((a, b) => a + b);
  }

  // Kolmogorov-Smirnov Test
  double calculateKSStatistic(List<double> predictions, List<double> actuals) {
    if (predictions.length != actuals.length || predictions.isEmpty) {
      return 0;
    }

    // Sort the data
    predictions.sort();
    actuals.sort();

    final n = predictions.length;
    double maxDiff = 0;

    for (int i = 0; i < n; i++) {
      final ecdfPred = (i + 1) / n;
      final ecdfActual = (actuals.indexOf(predictions[i]) + 1) / n;
      final diff = (ecdfPred - ecdfActual).abs();

      if (diff > maxDiff) {
        maxDiff = diff;
      }
    }

    return maxDiff;
  }

  void updateStockMetrics(StockValidation stock) {
    if (stock.actualPrice == null || stock.currentPrediction == null) return;

    // For demonstration, we'll use a small window of recent predictions
    // In a real app, you'd want to fetch historical predictions
    final predictions = [stock.currentPrediction];
    final actuals = [stock.actualPrice!];

    final errors = predictions
        .asMap()
        .entries
        .map((e) => actuals[e.key] - e.value)
        .toList();

    final rmse = calculateRMSE(predictions, actuals);
    final mle = calculateMLE(errors);
    final ksStatistic = calculateKSStatistic(predictions, actuals);

    setState(() {
      final index = stocks.indexWhere((s) => s.symbol == stock.symbol);
      if (index != -1) {
        stocks[index] = stocks[index].copyWith(
          rmse: rmse,
          mle: mle,
          ksStatistic: ksStatistic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              text: "Validation",
              name: widget.name,
              lastName: widget.lastName,
            ),
            SizedBox(height: defaultPadding),
            if (isLoading)
              if (isLoading)
                buildShimmerLoading()
              else if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              else if (stocks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No companies selected in your watchlist',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else ...[
                buildSectionHeader('Your watchlist'),
                ...stocks
                    .map((stock) => buildStockValidationCard(stock))
                    .toList(),
                SizedBox(height: defaultPadding),
                buildSectionHeader('Validation Summary'),
                buildValidationSummary(),
              ],
          ],
        ),
      ),
    );
  }

  Widget buildStockValidationCard(StockValidation stock) {
    final isExpanded = expandedStock == stock.symbol;
    final priceDifference = stock.actualPrice != null
        ? stock.actualPrice! - stock.currentPrediction
        : null;
    final percentageDifference = stock.actualPrice != null
        ? (priceDifference! / stock.currentPrediction) * 100
        : null;

    return Card(
      color: Color(0xFFF4FAFF),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              stock.symbol,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              generateTicker(stock.name),
              style: TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  expandedStock = isExpanded ? null : stock.symbol;
                });
              },
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price input section
                  buildPriceInputSection(stock),
                  SizedBox(height: 16),

                  // Price comparison
                  if (stock.actualPrice != null) ...[
                    buildPriceComparison(
                      stock.currentPrediction,
                      stock.actualPrice!,
                      priceDifference!,
                      percentageDifference!,
                    ),
                    SizedBox(height: 16),
                  ],

                  // Statistical metrics
                  buildStatisticalMetrics(stock),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildPriceInputSection(StockValidation stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Actual Price',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter current market price',
            suffixText: 'Zig',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            setState(() {
              if (value.isNotEmpty) {
                final newPrice = double.tryParse(value);
                if (newPrice != null) {
                  stock.actualPrice = newPrice;
                  updateStockMetrics(stock);
                }
              } else {
                stock.actualPrice = null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildPriceComparison(
    double predicted,
    double actual,
    double difference,
    double percentageDiff,
  ) {
    final isPositive = difference >= 0;
    final diffColor = isPositive ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Comparison',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Predicted Price:'),
            Text('\$${predicted.toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Actual Price:'),
            Text('\$${actual.toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Difference:'),
            Text(
              '${isPositive ? '+' : ''}\$${difference.abs().toStringAsFixed(2)} '
              '(${isPositive ? '+' : ''}${percentageDiff.abs().toStringAsFixed(2)}%)',
              style: TextStyle(color: diffColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStatisticalMetrics(StockValidation stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prediction Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            buildMetricChip(
                'Current', '\$${stock.currentPrediction.toStringAsFixed(2)}'),
            if (stock.previousPrediction != null)
              buildMetricChip('Previous',
                  '\$${stock.previousPrediction!.toStringAsFixed(2)}'),
            if (stock.rmse != 0)
              buildMetricChip('RMSE', stock.rmse.toStringAsFixed(4)),
            if (stock.mle != 0)
              buildMetricChip('MLE', stock.mle.toStringAsFixed(4)),
            if (stock.ksStatistic != 0)
              buildMetricChip('KS Stat', stock.ksStatistic.toStringAsFixed(4)),
          ],
        ),
      ],
    );
  }

  Widget buildMetricChip(String label, String value) {
    return Chip(
      backgroundColor: Colors.blue[50],
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildValidationSummary() {
    final stocksWithActualPrices =
        stocks.where((s) => s.actualPrice != null).toList();

    if (stocksWithActualPrices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Enter actual prices to see validation summary',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Calculate average metrics
    final avgRmse =
        stocksWithActualPrices.map((s) => s.rmse).reduce((a, b) => a + b) /
            stocksWithActualPrices.length;
    final avgMle =
        stocksWithActualPrices.map((s) => s.mle).reduce((a, b) => a + b) /
            stocksWithActualPrices.length;
    final avgKs = stocksWithActualPrices
            .map((s) => s.ksStatistic)
            .reduce((a, b) => a + b) /
        stocksWithActualPrices.length;

    // Calculate average stock price for context
    final avgStockPrice = stocksWithActualPrices
            .map((s) => s.actualPrice!)
            .reduce((a, b) => a + b) /
        stocksWithActualPrices.length;

    return Card(
      color: Color(0xFFF4FAFF),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Model Performance Evaluation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildMetricWithInterpretation(
                  'RMSE',
                  avgRmse.toStringAsFixed(4),
                  _interpretRMSE(avgRmse, avgStockPrice),
                  Icons.show_chart,
                ),
                _buildMetricWithInterpretation(
                  'MLE',
                  avgMle.toStringAsFixed(4),
                  _interpretMLE(avgMle),
                  Icons.psychology,
                ),
                _buildMetricWithInterpretation(
                  'KS Stat',
                  avgKs.toStringAsFixed(4),
                  _interpretKS(avgKs),
                  Icons.compare_arrows,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Key to Interpretation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildInterpretationGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricWithInterpretation(
      String title, String value, String interpretation, IconData icon) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: primaryColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            interpretation,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _interpretRMSE(double rmse, double avgPrice) {
    final percentage = (rmse / avgPrice) * 100;
    if (percentage < 1) return 'Excellent accuracy\n(Error <1% of price)';
    if (percentage < 3) return 'Good accuracy\n(Error 1-3% of price)';
    if (percentage < 5) return 'Moderate accuracy\n(Error 3-5% of price)';
    return 'Low accuracy\n(Error >5% of price)';
  }

  String _interpretMLE(double mle) {
    // Since MLE is typically negative, closer to 0 is better
    if (mle > -5) return 'Excellent model fit';
    if (mle > -10) return 'Good model fit';
    if (mle > -20) return 'Moderate model fit';
    return 'Poor model fit';
  }

  String _interpretKS(double ks) {
    if (ks < 0.1) return 'Excellent distribution match';
    if (ks < 0.2) return 'Good distribution match';
    if (ks < 0.3) return 'Moderate distribution difference';
    return 'Significant distribution difference';
  }

  Widget _buildInterpretationGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideItem('RMSE (Root Mean Square Error)',
            'Measures average prediction error. Lower is better.'),
        _buildGuideItem('MLE (Maximum Likelihood Estimate)',
            'Measures how well model explains observed data. Closer to 0 is better.'),
        _buildGuideItem('KS Stat (Kolmogorov-Smirnov)',
            'Measures difference between predicted and actual distributions. Lower is better.'),
        SizedBox(height: 8),
        Text(
          'Note: Metrics are calculated across all stocks with entered prices.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

Widget buildShimmerLoading() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      children: [
        // Header shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 200,
            height: 30,
            color: Colors.white,
          ),
        ),
        SizedBox(height: defaultPadding),

        // Section header shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),

        // Stock cards shimmer
        Column(
          children: List.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 100, height: 20, color: Colors.white),
                            SizedBox(height: 8),
                            Container(
                                width: 150, height: 16, color: Colors.white),
                            SizedBox(height: 16),
                            Container(
                                width: double.infinity,
                                height: 40,
                                color: Colors.white),
                            SizedBox(height: 8),
                            Container(
                                width: 120, height: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  )),
        ),

        SizedBox(height: defaultPadding),

        // Section header shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),

        // Summary shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(width: 200, height: 20, color: Colors.white),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      3,
                      (index) => Container(
                            width: 100,
                            height: 80,
                            color: Colors.white,
                          )),
                ),
                SizedBox(height: 16),
                Column(
                  children: List.generate(
                      4,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                                width: double.infinity,
                                height: 12,
                                color: Colors.white),
                          )),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class StockValidation {
  final String symbol;
  final String name;
  final double currentPrediction;
  final double? previousPrediction;
  double? actualPrice;

  final double rmse;
  final double mle;
  final double mse;
  final double ksStatistic;

  StockValidation({
    required this.symbol,
    required this.name,
    required this.currentPrediction,
    this.previousPrediction,
    this.actualPrice,
    required this.rmse,
    required this.mle,
    required this.ksStatistic,
    required this.mse,
  });

  StockValidation copyWith({
    String? symbol,
    String? name,
    double? currentPrediction,
    double? previousPrediction,
    double? actualPrice,
    double? rmse,
    double? mle,
    double? mse,
    double? ksStatistic,
  }) {
    return StockValidation(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrediction: currentPrediction ?? this.currentPrediction,
      previousPrediction: previousPrediction ?? this.previousPrediction,
      actualPrice: actualPrice ?? this.actualPrice,
      rmse: rmse ?? this.rmse,
      mle: mle ?? this.mle,
      ksStatistic: ksStatistic ?? this.ksStatistic,
      mse: mse ?? this.mse,
    );
  }
}
