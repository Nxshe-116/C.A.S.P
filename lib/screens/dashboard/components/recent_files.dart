// ignore_for_file: deprecated_member_use, dead_code

import 'package:admin/models/tickers.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/models/predictions.dart'; // Ensure this import is correct
import 'package:admin/services/services.dart'; // Ensure this import is correct
import 'package:admin/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Ensure this import is correct
import 'package:intl/intl.dart';

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
        predictions[stock] = prediction!;
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
                return Center(child: Text('No watchlist'));
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
        subtitle: Text(
          stockTicker,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        ),
        trailing: Text(
          '\$${prediction.currentPrediction.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onTap: press,
      ),
    );
  }
}

class ChartWidget extends StatefulWidget {
  final String? stock;
  const ChartWidget({Key? key, this.stock}) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  ApiService apiService = ApiService();
  Prediction? predictionWithoutClimate;
  PredictionWithClimate? predictionWithClimate;
  bool isLoading = false;
  String? errorMessage;
  List<ChartData> chartData = [];
  List<ChartData> chartData1 = [];
  bool displayClimateAdjustment = false;

  @override
  void didUpdateWidget(ChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stock != oldWidget.stock && widget.stock != null) {
      _fetchData(widget.stock!);
    }
  }

  Future<void> _fetchData(String symbol) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      chartData.clear();
      chartData1.clear();
    });

    try {
      final withoutClimate =
          await apiService.fetchPredictionWithoutClimate(symbol);
      final withClimate = await apiService.fetchPredictionWithClimate(symbol);

      if (withoutClimate == null || withClimate == null) {
        throw Exception('Failed to load prediction data');
      }

      // Use climate-adjusted data for the chart
      chartData = withClimate.weeklyPredictions.map((weeklyPred) {
        return ChartData(
          x: DateTime.now().add(Duration(days: 7 * weeklyPred.week)),
          open: weeklyPred.open,
          high: weeklyPred.high,
          low: weeklyPred.low,
          close: weeklyPred.adjustedClose ?? weeklyPred.close,
        );
      }).toList();
      chartData1 = withoutClimate.weeklyPredictions.map((weeklyPred) {
        return ChartData(
          x: DateTime.now().add(Duration(days: 7 * weeklyPred.week)),
          open: weeklyPred.open,
          high: weeklyPred.high,
          low: weeklyPred.low,
          close: weeklyPred.adjustedClose ?? weeklyPred.close,
        );
      }).toList();

      setState(() {
        predictionWithoutClimate = withoutClimate;
        predictionWithClimate = withClimate;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
      debugPrint('Error in _fetchData: $e');
    }
  }

  Widget _buildShimmerChart() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Column(
        children: [
          // Prediction Text Display
          Container(
            height: 100,
            child: Center(
                child: widget.stock == null
                    ? Text(
                        'No stock selected',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    : isLoading
                        ? _buildShimmerChart()
                        : errorMessage != null
                            ? Text(
                                'Error: $errorMessage',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              )
                            : Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4FAFF),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  leading: Icon(
                                    Icons
                                        .thermostat_auto, // Climate-related icon
                                    color: displayClimateAdjustment
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[600],
                                  ),
                                  title: Text(
                                    "Display Climate Adjustment",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color,
                                    ),
                                  ),
                                  trailing: Transform.scale(
                                    scale: 0.6, // Slightly smaller switch
                                    child: Switch.adaptive(
                                      value: displayClimateAdjustment,
                                      onChanged: (value) {
                                        setState(() {
                                          displayClimateAdjustment = value;
                                        });
                                      },
                                      activeColor: primaryColor,
                                      thumbColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (states) => states.contains(
                                                MaterialState.selected)
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      displayClimateAdjustment =
                                          !displayClimateAdjustment;
                                    });
                                  },
                                ),
                              )),
          ),

          // Chart Visualization
          Expanded(
            child: isLoading
                ? _buildShimmerChart()
                : chartData.isEmpty
                    ? Center(child: Container())
                    : SfCartesianChart(
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true, // Enable pinch zoom
                          enableDoubleTapZooming:
                              true, // Enable double tap zoom
                          enablePanning: true, // Enable panning
                          enableSelectionZooming: true, // Enable selection zoom
                          selectionRectBorderColor: Colors.red,
                          selectionRectColor: Colors.grey.withOpacity(0.2),
                        ),
                        primaryXAxis: DateTimeAxis(
                          title: AxisTitle(text: 'Weeks'),
                          intervalType: DateTimeIntervalType.days,
                          interval: 7,
                          majorGridLines: const MajorGridLines(width: 0.15),
                          dateFormat:
                              DateFormat('MMM dd'), // Simple date format
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 100, // Set lower bound
                          maximum: 900, // Set upper bound
                          interval: 100, // Gap between Y-axis labels
                          numberFormat: NumberFormat.currency(
                            symbol: 'ZiG ',
                            decimalDigits: 2,
                            customPattern: '¤#,##0.00',
                          ),
                        ),
                        // palette: <Color>[
                        //   Colors.teal,
                        //   Colors.orange,
                        //   Colors.brown
                        // ],
                        series: <CartesianSeries>[
                          CandleSeries<ChartData, DateTime>(
                            name: 'Stock Price',
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.x,
                            lowValueMapper: (ChartData data, _) => data.low,
                            highValueMapper: (ChartData data, _) => data.high,
                            openValueMapper: (ChartData data, _) => data.open,
                            closeValueMapper: (ChartData data, _) => data.close,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                            width: 0.25,
                            spacing: 0.2,
                          ),
                          if (displayClimateAdjustment)
                            HiloOpenCloseSeries<ChartData, DateTime>(
                              name: 'Stock Price',
                              dataSource: chartData1,
                              xValueMapper: (ChartData data, _) => data.x,
                              lowValueMapper: (ChartData data, _) => data.low,
                              highValueMapper: (ChartData data, _) => data.high,
                              openValueMapper: (ChartData data, _) => data.open,
                              closeValueMapper: (ChartData data, _) =>
                                  data.close,
                              bearColor: Colors
                                  .lightGreenAccent, // Color when close < open
                              bullColor: Colors.redAccent,
                              // borderRadius: BorderRadius.all(Radius.circular(2)),
                              //  width: 0.25,
                              spacing: 0.2,
                            ),
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime x;
  final double open;
  final double high;
  final double low;
  final double close;

  ChartData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
