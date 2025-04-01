import 'package:admin/constants.dart';
import 'package:admin/models/tickers.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:admin/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
            mae: 0, // Will be updated from real-time data if available
            rSquared: 0, // Will be updated from real-time data if available
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
                // These metrics would come from a different endpoint if available
                // mse: 0, // Placeholder - update if you have this data
                // rmse: 0, // Placeholder - update if you have this data
                // mae: 0, // Placeholder - update if you have this data
                // rSquared: 0, // Placeholder - update if you have this data
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
              Center(child: CircularProgressIndicator())
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
                stock.actualPrice = double.tryParse(value);
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
            // Only show metrics if they have non-zero values
            if (stock.mse != 0)
              buildMetricChip('MSE', stock.mse.toStringAsFixed(2)),
            if (stock.rmse != 0)
              buildMetricChip('RMSE', stock.rmse.toStringAsFixed(2)),
            if (stock.mae != 0)
              buildMetricChip('MAE', stock.mae.toStringAsFixed(2)),
            if (stock.rSquared != 0)
              buildMetricChip('R²', stock.rSquared.toStringAsFixed(2)),
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
    final avgMse =
        stocksWithActualPrices.map((s) => s.mse).reduce((a, b) => a + b) /
            stocksWithActualPrices.length;
    final avgRmse =
        stocksWithActualPrices.map((s) => s.rmse).reduce((a, b) => a + b) /
            stocksWithActualPrices.length;
    final avgMae =
        stocksWithActualPrices.map((s) => s.mae).reduce((a, b) => a + b) /
            stocksWithActualPrices.length;
    final avgRSquared =
        stocksWithActualPrices.map((s) => s.rSquared).reduce((a, b) => a + b) /
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
              'Average Model Performance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                buildSummaryMetric(
                    'Mean Squared Error', avgMse.toStringAsFixed(2)),
                buildSummaryMetric(
                    'Root Mean Squared Error', avgRmse.toStringAsFixed(2)),
                buildSummaryMetric(
                    'Mean Absolute Error', avgMae.toStringAsFixed(2)),
                buildSummaryMetric('R Squared', avgRSquared.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
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

class StockValidation {
  final String symbol;
  final String name;
  final double currentPrediction;
  final double? previousPrediction; // Add this field
  double? actualPrice;

  final double mse;
  final double rmse;
  final double mae;
  final double rSquared;

  StockValidation({
    required this.symbol,
    required this.name,
    required this.currentPrediction,
    this.previousPrediction,
    this.actualPrice,
    required this.mse,
    required this.rmse,
    required this.mae,
    required this.rSquared,
  });

  StockValidation copyWith({
    String? symbol,
    String? name,
    double? currentPrediction,
    double? previousPrediction,
    double? actualPrice,
    // Remove these if not using metrics:
    // double? mse,
    // double? rmse,
    // double? mae,
    // double? rSquared,
  }) {
    return StockValidation(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrediction: currentPrediction ?? this.currentPrediction,
      previousPrediction: previousPrediction ?? this.previousPrediction,
      actualPrice: actualPrice ?? this.actualPrice,
      // Remove these if not using metrics:
      mse: mse ?? this.mse,
      rmse: rmse ?? this.rmse,
      mae: mae ?? this.mae,
      rSquared: rSquared ?? this.rSquared,
    );
  }
}


