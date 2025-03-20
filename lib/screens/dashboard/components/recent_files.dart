import 'package:admin/models/tickers.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/models/predictions.dart'; // Ensure this import is correct
import 'package:admin/services/services.dart'; // Ensure this import is correct
import 'package:admin/constants.dart'; // Ensure this import is correct

class RecentFiles extends StatefulWidget {
  final String userId;
  const RecentFiles({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  String? selectedStock;
  final ApiService apiService = ApiService();
  List<String> watchlist = [];
  late Future<Map<String, Prediction>> predictionsFuture;

  @override
  void initState() {
    super.initState();
    predictionsFuture = Future.value({}); // Initialize with an empty Future
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
        final List<dynamic> selectedCompanies =
            userData?['selectedCompanies'] ?? [];
        final List<String> companies = selectedCompanies
            .map((company) => company['name'] as String)
            .toList();

        if (mounted) {
          setState(() {
            watchlist = companies;
          });
        }

        // Fetch predictions for all stocks in the watchlist
        predictionsFuture = _fetchAllPredictions(watchlist);
      } else {
        print('User document not found.');
      }
    } catch (e) {
      print('Error fetching selected companies: $e');
    }
  }

  Future<Map<String, Prediction>> _fetchAllPredictions(
      List<String> watchlist) async {
    final Map<String, Prediction> predictions = {};
    for (final stock in watchlist) {
      try {
        final prediction =
            await apiService.fetchPredictionWithoutClimate(stock);
        predictions[stock] = prediction;
      } catch (e) {
        print('Error fetching prediction for $stock: $e');
      }
    }
    return predictions;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        Responsive.isMobile(context); // Assuming you have a Responsive class

    return Container(
      padding: EdgeInsets.all(isMobile ? defaultPadding / 2 : defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Watchlist",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: isMobile ? 16 : 18, // Adjust font size for mobile
                ),
          ),
          SizedBox(height: isMobile ? defaultPadding / 2 : defaultPadding),
          FutureBuilder<Map<String, Prediction>>(
            future: predictionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a shimmer effect while loading
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: watchlist.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Container(
                            height: 20,
                            color: Colors.white,
                          ),
                          subtitle: Container(
                            height: 15,
                            color: Colors.white,
                          ),
                          trailing: Container(
                            width: 50,
                            height: 20,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No prediction data available'));
              } else {
                final predictions = snapshot.data!;
                return SizedBox(
                  height: isMobile ? 600 : 300, // Adjust height for mobile
                  child: isMobile
                      ? Column(
                          children: [
                            // List on top for mobile
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: watchlist.length,
                                itemBuilder: (context, index) {
                                  final stock = watchlist[index];
                                  final prediction = predictions[stock];

                                  if (prediction == null) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ListTile(
                                        title: Text(stock),
                                        subtitle:
                                            Text('No prediction available'),
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: StockListTile(
                                      stockName: stock,
                                      stockTicker: generateTicker(stock),
                                      prediction: prediction,
                                      press: () {
                                        if (mounted) {
                                          setState(() {
                                            selectedStock = stock;
                                          });
                                        }
                                      },
                                      uid: widget.userId,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: defaultPadding),
                            // Chart at the bottom for mobile
                            Container(
                              height:
                                  300, // Fixed height for the chart on mobile
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: ChartWidget(stock: selectedStock),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            // List on the left for desktop
                            Expanded(
                              flex: 2,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: watchlist.length,
                                itemBuilder: (context, index) {
                                  final stock = watchlist[index];
                                  final prediction = predictions[stock];

                                  if (prediction == null) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: ListTile(
                                        title: Text(stock),
                                        subtitle:
                                            Text('No prediction available'),
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: StockListTile(
                                      stockName: stock,
                                      stockTicker: generateTicker(stock),
                                      prediction: prediction,
                                      press: () {
                                        if (mounted) {
                                          setState(() {
                                            selectedStock = stock;
                                          });
                                        }
                                      },
                                      uid: widget.userId,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: defaultPadding),
                            // Chart on the right for desktop
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 500,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: ChartWidget(stock: selectedStock),
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any ongoing asynchronous operations here
    super.dispose();
  }
}

class StockListTile extends StatelessWidget {
  final String stockName, stockTicker, uid;
  final Prediction prediction;
  final VoidCallback press;

  const StockListTile({
    Key? key,
    required this.stockName,
    required this.stockTicker,
    required this.uid,
    // required this.priceChange,
    required this.press,
    required this.prediction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentageChange = ((prediction.predictedClose - 859) / 100) * 100;
    String formattedChange = percentageChange >= 0
        ? "+${percentageChange.toStringAsFixed(2)}%"
        : "${percentageChange.toStringAsFixed(2)}%";
    return Card(
      color: Color(0xFFF4FAFF),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          stockName,
          style: TextStyle(fontSize: 12),
        ),
        subtitle: Text(stockTicker),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${prediction.predictedClose.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              formattedChange,
              style: TextStyle(
                color: percentageChange >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        onTap: press,
      ),
    );
  }
}

class ChartWidget extends StatelessWidget {
  final String? stock;

  const ChartWidget({Key? key, this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Text(
          stock != null ? 'Chart for $stock' : 'No stock selected',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// class ChartWidget extends StatelessWidget {
//   final StockInfo? stock;

//   const ChartWidget({Key? key, this.stock}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     List<ChartData> chartData = [];

//     if (stock != null) {
//       // Populate the chart data based on the selected stock
//       for (int i = 0; i < stock!.priceHistory.length; i++) {
//         chartData.add(ChartData(
//           x: DateTime.now().subtract(Duration(
//               days: (stock!.priceHistory.length - i - 1) *
//                   30)), // Adjusted to monthly intervals
//           open: stock!.priceHistory[i].open,
//           high: stock!.priceHistory[i].high,
//           low: stock!.priceHistory[i].low,
//           close: stock!.priceHistory[i].closingPrice,
//         ));
//       }
//     }

//     return Container(
//       height: 200, // Set height for the chart
//       child: SfCartesianChart(
//         primaryXAxis: DateTimeAxis(
//           intervalType: DateTimeIntervalType.months,
//           interval: 1, // Set to one month intervals
//           majorGridLines: const MajorGridLines(width: 0),
//         ),
//         series: <CartesianSeries>[
//           // Candle series for stock price data
//           CandleSeries<ChartData, DateTime>(
//               name: 'Stock Price',
//               dataSource: chartData,
//               xValueMapper: (ChartData data, _) => data.x,
//               lowValueMapper: (ChartData data, _) => data.low,
//               highValueMapper: (ChartData data, _) => data.high,
//               openValueMapper: (ChartData data, _) => data.open,
//               closeValueMapper: (ChartData data, _) => data.close,
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               width: 0.5,
//               spacing: 0.2),
//         ],
//         tooltipBehavior: TooltipBehavior(enable: true),
//       ),
//     );
//   }
// }

class ChartData {
  ChartData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final DateTime x;
  final double open;
  final double high;
  final double low;
  final double close;
}
