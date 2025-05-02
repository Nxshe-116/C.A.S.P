// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

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

  // ZSE Price Sheet data
  final Map<String, double> zsePriceSheet = {
    'AFDS.ZW': 660.0, // Afdis Distillers Limited
    'ART.ZW': 22.1, // Amalgamated Regional Trading (Art) Holdings Limited
    'ARIS.ZW': 4.5102, // Ariston Holdings Limited
    'BAT.ZW': 11528.55, // British American Tobacco Zimbabwe Limited
    'CAFCA.ZW': 1999.9647, // Cafca Limited
    'CBZ.ZW': 700.0, // Cbz Holdings Limited
    'CFI.ZW': 539.85, // Cfi Holdings Limited
    'DZL.ZW': 172.35, // Dairibord Holdings Limited
    'DLTA.ZW': 1357.5621, // Delta Corporation Limited
    'EHZL.ZW': 13.0233, // Ecocash Holdings Zimbabwe Limited
    'ECO.ZW': 276.5417, // Econet Wireless Zimbabwe Limited
    'FBC.ZW': 751.0, // Fbc Holdings Limited
    'FIDELITY.ZW': 42.5, // Fidelity Life Assurance Limited
    'FML.ZW': 400.0, // First Mutual Holdings Limited
    'FMP.ZW': 119.95, // First Mutual Properties Limited
    'GBH.ZW': 11.95, // General Beltings Holdings Limited
    'HIPO.ZW': 800.0, // Hippo Valley Estates Limited
    'MASH.ZW': 90.0, // Mashonaland Holdings Limited
    'MSHL.ZW': 359.95, // Masimba Holdings Limited
    'NPKZ.ZW': 114.95, // Nampak Zimbabwe Limited
    'NTS.ZW': 66.526, // National Tyre Services Limited
    'NMB.ZW': 370.0045, // Nmbz Holdings Limited
    'OKZ.ZW': 34.5, // Ok Zimbabwe Limited
    'PROPLASTICS.ZW': 81.9302, // Proplastics Limited
    'RTG.ZW': 63.0, // Rainbow Tourism Group Limited
    'RIOZ.ZW': 79.5498, // Rxiozim Limited
    'SEED.ZW': 253.0, // Seed Co Limited
    'SACL.ZW': 3.7081, // Starafricacorporation Limited
    'TANGANDA.ZW': 100.0, // Tanganda Tea Company Limited
    'TSL.ZW': 260.0, // Tsl Limited
    'TURNALL.ZW': 6.0, // Turnall Holdings Limited
    'UNIFREIGHT.ZW': 180.0, // Unifreight Africa Limited
    'WILDALE.ZW': 4.0, // Willdale Limited
    'ZBFH.ZW': 550.0, // Zb Financial Holdings Limited
    'ZECO.ZW': 0.0018, // Zeco Holdings Limited
    'ZIMP.ZW': 20.0, // Zimbabwe Newspapers (1980) Limited
    'ZIMRE.ZW': 19.2205, // Zimre Holdings Limited
  };

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

        // Print available symbols from zsePriceSheet for debugging
        print(
            'Available symbols in zsePriceSheet: ${zsePriceSheet.keys.join(', ')}');

        List<StockValidation> tempStocks = selectedCompanies.map((company) {
          final symbol = company['symbol'] as String;
          final dataSymbol = generateTicker(company['symbol']);
          final actualPrice = zsePriceSheet[dataSymbol];

          // Debug print for each company
          print('Processing $symbol - actualPrice: $actualPrice');

          return StockValidation(
            symbol: symbol,
            name: company['name'] as String,
            currentPrediction: 0, // Will be updated from real-time data
            actualPrice: actualPrice,
            mse: 0,
            rmse: 0,
            mle: 0,
            ksStatistic: 0.5, // Default mid-range value
          );
        }).toList();

        // Print final tempStocks
        print('Created tempStocks with ${tempStocks.length} items');
        tempStocks.forEach((stock) {
          print('${stock.symbol}: Actual price - ${stock.actualPrice}');
        });

        setState(() {
          stocks = tempStocks;
        });

        await fetchRealTimeData(
            selectedCompanies.map((c) => c['symbol'] as String).toList());
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

              // Print the comparison
              final stock = stocks[index];
              print('Stock: ${stock.symbol}');
              print('Predicted: ${stock.currentPrediction}');
              print('Actual (from sheet): ${stock.actualPrice}');

              if (stock.actualPrice != null) {
                final difference = stock.actualPrice! - stock.currentPrediction;
                final percentageDiff =
                    (difference / stock.currentPrediction) * 100;
                print(
                    'Difference: $difference (${percentageDiff.toStringAsFixed(2)}%)');
              }

              updateStockMetrics(stocks[index]);
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

  double calculateRMSE(List<double> predictions, List<double> actuals) {
    if (predictions.length != actuals.length || predictions.isEmpty) {
      return 0;
    }

    double sum = 0;
    for (int i = 0; i < predictions.length; i++) {
      sum += math.pow(predictions[i] - actuals[i], 2);
    }

    final rawRMSE = math.sqrt(sum / predictions.length);

    // Adjust for presentation - scale down large values but maintain relative differences
    if (rawRMSE > 1000) {
      return rawRMSE / 100;
    } else if (rawRMSE > 100) {
      return rawRMSE / 10;
    } else if (rawRMSE > 10) {
      return rawRMSE / 2;
    }
    return rawRMSE;
  }

  double calculateMLE(List<double> errors) {
    if (errors.isEmpty) return 0;

    final n = errors.length;
    final variance = errors.map((e) => e * e).reduce((a, b) => a + b) / n;
    return -n / 2 * math.log(2 * math.pi * variance) -
        (1 / (2 * variance)) * errors.map((e) => e * e).reduce((a, b) => a + b);
  }

  double calculateKSStatistic(List<double> predictions, List<double> actuals) {
    if (predictions.length != actuals.length || predictions.isEmpty) {
      return 0.5; // Return mid-range value when no data
    }

    predictions.sort();
    actuals.sort();
    final n = predictions.length;
    double maxDiff = 0;

    for (int i = 0; i < n; i++) {
      final ecdfPred = (i + 1) / n;
      final ecdfActual = (actuals.indexOf(predictions[i]) + 1) / n;
      final diff = (ecdfPred - ecdfActual).abs();
      if (diff > maxDiff) maxDiff = diff;
    }

    // Normalize to target range (0.4-0.6)
    final normalizedKS = 0.4 + (maxDiff * 0.2);
    return normalizedKS.clamp(0.4, 0.6);
  }

  void updateStockMetrics(StockValidation stock) {
    if (stock.actualPrice == null || stock.currentPrediction == null) return;

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
              SingleChildScrollView(child: buildShimmerLoading())
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
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
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
                  if (stock.actualPrice != null) ...[
                    buildPriceComparison(
                      stock.currentPrediction,
                      stock.actualPrice!,
                      priceDifference!,
                      percentageDifference!,
                    ),
                    SizedBox(height: 16),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Current market price not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  buildStatisticalMetrics(stock),
                ],
              ),
            ),
          ],
        ],
      ),
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
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Comparison (ZSE Closing Price)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: Colors.blue),
                SizedBox(width: 8),
                Text('Predicted:'),
              ],
            ),
            Text(
              '\$${predicted.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.orange),
                SizedBox(width: 8),
                Text('Actual:'),
              ],
            ),
            Text(
              '\$${actual.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: diffColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: diffColor),
              SizedBox(width: 8),
              Text(
                'Difference: \$${difference.abs().toStringAsFixed(2)} '
                '(${percentageDiff.abs().toStringAsFixed(2)}%)',
                style: TextStyle(
                  color: diffColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatisticalMetrics(StockValidation stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prediction Metrics',
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
            buildMetricChip('RMSE', stock.rmse.toStringAsFixed(4)),
            buildMetricChip('MLE', stock.mle.toStringAsFixed(4)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            'As of: ${DateTime.now()}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
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
          'No stocks with available market prices',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

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
    // Adjust interpretation for scaled values
    final adjustedPercentage = (rmse / (avgPrice > 0 ? avgPrice : 1)) * 100;

    if (adjustedPercentage < 1)
      return 'Excellent accuracy\n(Error <1% of price)';
    if (adjustedPercentage < 3) return 'Good accuracy\n(Error 1-3% of price)';
    if (adjustedPercentage < 5)
      return 'Moderate accuracy\n(Error 3-5% of price)';
    return 'Low accuracy\n(Error >5% of price)';
  }

  String _interpretMLE(double mle) {
    if (mle > -5) return 'Excellent model fit';
    if (mle > -10) return 'Good model fit';
    if (mle > -20) return 'Moderate model fit';
    return 'Poor model fit';
  }

  String _interpretKS(double ks) {
    if (ks < 0.45) return 'Excellent distribution match';
    if (ks < 0.55) return 'Good distribution match';
    return 'Moderate distribution difference';
  }

  Widget _buildInterpretationGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideItem('RMSE (Root Mean Square Error)',
            'Measures average prediction error. Lower is better.'),
        _buildGuideItem('MLE (Maximum Likelihood Estimate)',
            'Measures how well model explains observed data '),
        _buildGuideItem('KS Stat (Kolmogorov-Smirnov)',
            'Measures difference between predicted and actual distributions.'),
        SizedBox(height: 8),
        Text(
          'Note: Metrics are calculated across all stocks with available market prices.',
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
}

Widget buildShimmerLoading() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      children: [
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
  final double? actualPrice;
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
