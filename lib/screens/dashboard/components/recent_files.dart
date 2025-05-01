// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:admin/models/company.dart';
import 'package:admin/models/montlhy.dart';
import 'package:admin/models/notifications.dart';
import 'package:admin/models/tickers.dart';
import 'package:admin/responsive.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/models/predictions.dart'; // Ensure this import is correct
import 'package:admin/services/services.dart'; // Ensure this import is correct
import 'package:admin/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Ensure this import is correct
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<PredictionEntry> historicalData = [];
  List<PredictionChartData> parsedChartData = [];

  String? errorMessage;
  bool isLoading = true;

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

  Future<List<PredictionChartData>> getMonthlyPredictionChartData({
    required String symbol,
    required int year,
    required String month,
  }) async {
    try {
      final monthlyData = await apiService.fetchFullMonthlyData(
        symbol: symbol,
        year: year,
        month: month,
      );

      final predictions =
          monthlyData['weeklyPredictions'] as List<MonthlyPrediction>;

      // Convert weekly predictions to chart data
      return predictions.map((prediction) {
        // Create a DateTime for each week
        final date = DateTime(
          monthlyData['year'],
          _monthToNumber(monthlyData['month']),
          prediction.weekNumber * 7, // Approximate date for the week
        );

        parsedChartData = predictions.map((prediction) {
          // Use the actual year/month from your data
          final baseDate = DateTime(
              year, _monthToNumber(month), 1); // First day of the month
          final date =
              baseDate.add(Duration(days: 7 * (prediction.weekNumber - 1)));

          return PredictionChartData(
            date: date,
            actualPrice: prediction.actualPrice,
            normalPrediction: prediction.normalPrediction,
            climatePrediction: prediction.climatePrediction,
          );
        }).toList();

        print("Parsed chart data: $parsedChartData");
        return PredictionChartData(
          date: date,
          actualPrice: prediction.actualPrice,
          normalPrediction: prediction.normalPrediction,
          climatePrediction: prediction.climatePrediction,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting chart data: $e');
      rethrow;
    }
  }

  int _monthToNumber(String month) {
    final months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return months[month] ?? 1;
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
                  fontSize: isMobile ? 12 : 18, // Adjust font size for mobile
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
                                child: ChartWidget(
                                    stock: selectedStock,
                                    userId: widget.userId),
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
                                      //F   info: '',
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
                                  child: ChartWidget(
                                    stock: selectedStock,
                                    userId: widget.userId,
                                  ),
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

class StockListTile extends StatefulWidget {
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
    //  required this.info,
  }) : super(key: key);

  @override
  State<StockListTile> createState() => _StockListTileState();
}

class _StockListTileState extends State<StockListTile> {
  List<PredictionEntry> historicalData = [];
  String? errorMessage;
  bool isLoading = true;
  int _historyRetryCount = 0;
  final int _maxRetries = 3;
  final ApiService apiService = ApiService();
  @override
  void initState() {
    super.initState();

    fetchHistoricalPredictions(widget.stockName);
  }

  Future<void> fetchHistoricalPredictions(String symbol) async {
    try {
      setState(() => isLoading = true);
      final response = await apiService.fetchHistoricalPredictions(symbol);

      if (!mounted) return;

      setState(() {
        historicalData = response.historicalPredictions;
        errorMessage = null;
      });
    } catch (e) {
      if (_historyRetryCount < _maxRetries) {
        _historyRetryCount++;
        await Future.delayed(const Duration(seconds: 1));
        await fetchHistoricalPredictions(symbol);
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load historical data for $symbol';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }

    print('Historical data for $symbol: ${historicalData.length} entries');
  }

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
          widget.stockName,
          style: TextStyle(fontSize: 12),
        ),
        subtitle: Text(
          widget.stockTicker,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey),
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          offset: Offset(0, 40),
          onSelected: (String value) {
            handleMenuSelection(
                value, context, widget.stockName, widget.uid, historicalData);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'company_info',
              child: Text('Company Info'),
            ),
            PopupMenuItem<String>(
              value: 'remove',
              child: Text('Remove'),
            ),
            PopupMenuItem<String>(
              value: 'invest',
              child: Text('Invest'),
            ),
          ],
        ),
        onTap: widget.press,
      ),
    );
  }
}

class ChartWidget extends StatefulWidget {
  final String? stock;
  final String userId;
  const ChartWidget({Key? key, this.stock, required this.userId})
      : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  ApiService apiService = ApiService();
  Prediction? predictionWithoutClimate;
  PredictionWithClimate? predictionWithClimate;
  bool isLoading = false;
  String? errorMessage;
  List<ChartData> climateAdjustedData = [];
  List<ChartData> normalPredictionData = [];
  List<ChartData> historicalStockPrice = [];
  List<MonthlyPrediction> weeklyBreakdown = [];
  bool displayClimateAdjustment = false;
  ClimateMetrics? climateMetrics;
  List<PredictionChartData> parsedChartData = [];

  @override
  void didUpdateWidget(ChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stock != oldWidget.stock && widget.stock != null) {
      _fetchData(widget.stock!);
      fetchMonthlyData(widget.stock!, 2025, 'January');
      getMonthlyPredictionChartData(
        symbol: widget.stock!,
        year: 2025,
        month: 'January',
      );
    }
  }

  int _monthToNumber(String month) {
    final months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return months[month] ?? 1;
  }

  Future<List<PredictionChartData>> getMonthlyPredictionChartData({
    required String symbol,
    required int year,
    required String month,
  }) async {
    try {
      final monthlyData = await apiService.fetchFullMonthlyData(
        symbol: symbol,
        year: year,
        month: month,
      );

      final predictions =
          monthlyData['weeklyPredictions'] as List<MonthlyPrediction>;

      // Convert weekly predictions to chart data
      return predictions.map((prediction) {
        // Create a DateTime for each week
        final date = DateTime(
          monthlyData['year'],
          _monthToNumber(monthlyData['month']),
          prediction.weekNumber * 7, // Approximate date for the week
        );

        parsedChartData = predictions.map((prediction) {
          // Use the actual year/month from your data
          final baseDate = DateTime(
              year, _monthToNumber(month), 1); // First day of the month
          final date =
              baseDate.add(Duration(days: 7 * (prediction.weekNumber - 1)));

          return PredictionChartData(
            date: date,
            actualPrice: prediction.actualPrice,
            normalPrediction: prediction.normalPrediction,
            climatePrediction: prediction.climatePrediction,
          );
        }).toList();

        print("Parsed chart data: $parsedChartData");
        return PredictionChartData(
          date: date,
          actualPrice: prediction.actualPrice,
          normalPrediction: prediction.normalPrediction,
          climatePrediction: prediction.climatePrediction,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting chart data: $e');
      rethrow;
    }
  }

  Future<void> evaluateTrendAndNotify(
      String symbol, String uid, String companyName) async {
    if (climateAdjustedData.length < 3) return;

    int consecutiveIncreases = 0;
    for (int i = 1; i < climateAdjustedData.length; i++) {
      if (climateAdjustedData[i].close > climateAdjustedData[i - 1].close) {
        consecutiveIncreases++;
        if (consecutiveIncreases >= 3) {
          final notification = Notifications(
            message:
                'Stock $symbol has shown consistent growth for 3 weeks. Consider BUYING.',
            timestamp: DateTime.now(),
            title: 'Buy Opportunity: $companyName',
            userId: uid,
            notifId: UniqueKey().toString(),
          );
          await apiService.addNotificationToUser(uid, notification);
          return;
        }
      } else if (climateAdjustedData[i].close <
              climateAdjustedData[i - 1].close &&
          consecutiveIncreases >= 1) {
        final notification = Notifications(
          message:
              'Stock $symbol dropped in price. Consider SELLING if in portfolio.',
          timestamp: DateTime.now(),
          title: 'Sell Alert: $companyName',
          userId: uid,
          notifId: UniqueKey().toString(),
        );
        await apiService.addNotificationToUser(uid, notification);
        return;
      } else {
        consecutiveIncreases = 0; // Reset if not increasing
      }
    }
  }

  Future<void> _fetchData(String symbol) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      climateAdjustedData.clear();
      normalPredictionData.clear();
    });

    try {
      final withoutClimate =
          await apiService.fetchPredictionWithoutClimate(symbol);
      final withClimate = await apiService.fetchPredictionWithClimate(symbol);

      if (withoutClimate == null || withClimate == null) {
        throw Exception('Failed to load prediction data');
      }

      // Use climate-adjusted data for the chart
      climateAdjustedData = withClimate.weeklyPredictions.map((weeklyPred) {
        return ChartData(
          x: DateTime.now().add(Duration(days: 7 * weeklyPred.week)),
          open: weeklyPred.open,
          high: weeklyPred.high,
          low: weeklyPred.low,
          close: weeklyPred.adjustedClose ?? weeklyPred.close,
        );
      }).toList();

      normalPredictionData = withoutClimate.weeklyPredictions.map((weeklyPred) {
        return ChartData(
          x: DateTime.now().add(Duration(days: 7 * weeklyPred.week)),
          open: weeklyPred.open,
          high: weeklyPred.high,
          low: weeklyPred.low,
          close: weeklyPred.adjustedClose ?? weeklyPred.close,
        );
      }).toList();
      evaluateTrendAndNotify(symbol, widget.userId, symbol);
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

  // static int _monthToNumber(String month) {
  //   return DateFormat('MMMM').parse(month).month;
  // }

  Future<void> fetchMonthlyData(
      String selectedSymbol, int selectedYear, String selectedMonth) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      weeklyBreakdown.clear();
      climateAdjustedData.clear();
      normalPredictionData.clear();
      historicalStockPrice.clear();
    });

    try {
      final fullData = await apiService.fetchFullMonthlyData(
        symbol: selectedSymbol,
        year: selectedYear,
        month: selectedMonth,
      );

      if (fullData['weeklyPredictions'] == null) {
        throw Exception('No prediction data available');
      }

      // Prepare chart data for past predictions
      // climateAdjustedData = fullData['weeklyPredictions'].map<ChartData>((weekly) {
      //   // Ensure weekNumber is converted to int
      //   final weekNumber = (weekly.weekNumber is int ? weekly.weekNumber : weekly.weekNumber.toInt()) as int;

      //   return ChartData(
      //     x: DateTime(selectedYear, _monthToNumber(selectedMonth), 1)
      //         .add(Duration(days: 7 * (weekNumber - 1))),
      //     open: weekly.actualPrice,
      //     high: weekly.climatePrediction ?? weekly.actualPrice,
      //     low: weekly.normalPrediction,
      //     close: weekly.climatePrediction ?? weekly.actualPrice,
      //   );
      // }).toList();

      // normalPredictionData = fullData['weeklyPredictions'].map<ChartData>((weekly) {
      //   // Ensure weekNumber is converted to int
      //   final weekNumber = (weekly.weekNumber is int ? weekly.weekNumber : weekly.weekNumber.toInt()) as int;

      //   return ChartData(
      //     x: DateTime(selectedYear, _monthToNumber(selectedMonth), 1)
      //         .add(Duration(days: 7 * (weekNumber - 1))),
      //     open: weekly.actualPrice,
      //     high: weekly.normalPrediction,
      //     low: weekly.normalPrediction,
      //     close: weekly.normalPrediction,
      //   );
      // }).toList();

      print('fullData: $fullData');

      // // Prepare historical data
      // final historicalResponse =
      //     await apiService.fetchHistoricalPredictions(selectedSymbol);
      // historicalStockPrice =
      //     historicalResponse.historicalPredictions.map<ChartData>((entry) {
      //   return ChartData(
      //     x: DateFormat('yyyy-MM').parse(entry.date),
      //     open: entry.predictedClose,
      //     high: entry.predictedClose,
      //     low: entry.actualClose,
      //     close: entry.actualClose,
      //   );
      // }).toList();

      setState(() {
        weeklyBreakdown = fullData['weeklyPredictions'];
        climateMetrics = fullData['climateMetrics'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
      debugPrint('Error fetching monthly data: $e');
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
      height: 800,
      child: Column(children: [
        // Prediction Text Display
        Container(
          height: 100,
          child: Center(
              child: widget.stock == null
                  ? Text(
                      'No stock selected',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                  Icons.thermostat_auto, // Climate-related icon
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
                                    thumbColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (states) =>
                                          states.contains(WidgetState.selected)
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
          child: Stack(
            children: [
              // Main chart content
              isLoading
                  ? _buildShimmerChart()
                  : climateAdjustedData.isEmpty
                      ? Center(child: Container())
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: SfCartesianChart(
                            zoomPanBehavior: ZoomPanBehavior(
                              enablePinching: true,
                              enableDoubleTapZooming: true,
                              enablePanning: true,
                              enableSelectionZooming: true,
                              selectionRectBorderColor: Colors.red,
                              selectionRectColor: Colors.grey.withOpacity(0.2),
                            ),
                            primaryXAxis: DateTimeAxis(
                              title: AxisTitle(text: 'Weeks'),
                              intervalType: DateTimeIntervalType.days,
                              interval: 7,
                              majorGridLines: const MajorGridLines(width: 0.15),
                              dateFormat: DateFormat('MMM dd'),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 100,
                              maximum: 900,
                              interval: 100,
                              numberFormat: NumberFormat.currency(
                                symbol: 'ZiG ',
                                decimalDigits: 2,
                                customPattern: '¤#,##0.00',
                              ),
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<ChartData, DateTime>(
                                name: 'Climate Adjusted Close',
                                dataSource: climateAdjustedData,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.close,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                width: 0.25,
                                spacing: 0.2,
                                color: Colors.blueAccent,
                              ),
                              if (displayClimateAdjustment)
                                ColumnSeries<ChartData, DateTime>(
                                  name: 'Normal Predicted Close',
                                  dataSource: normalPredictionData,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) =>
                                      data.close,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                  width: 0.25,
                                  spacing: 0.2,
                                  color: Colors.orangeAccent,
                                ),
                            ],
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),

              // In the ChartWidget's build method, replace the Container with the button with this:
              if (!isLoading && climateAdjustedData.isNotEmpty)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.stock != null) {
                        showDetailedChart(
                            context,
                            widget.stock!,
                            climateAdjustedData,
                            normalPredictionData,
                            parsedChartData); //To find the historical Stock Prices
                      }
                    },
                    icon: Icon(Icons.zoom_in, color: Colors.white, size: 18),
                    label: Text(
                      "View detailed chart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.isMobile(context) ? 12 : 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding * 1.5,
                        vertical: defaultPadding /
                            (Responsive.isMobile(context) ? 2 : 1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                )
            ],
          ),
        )
      ]),
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

void handleMenuSelection(
  String value,
  BuildContext context,
  String companyInfo,
  String uid,
  List<PredictionEntry> historicalData,
) {
  switch (value) {
    case 'company_info':
      showCompanyInfoDialog(context, companyInfo, historicalData);
      break;
    case 'remove':
      showRemoveConfirmation(context);
      break;
    case 'invest':
      navigateToInvestScreen(context);
      break;
  }
}

void showCompanyInfoDialog(
  BuildContext context,
  String companyInfo,
  List<PredictionEntry> historicalData,
) {
  final company = getCompany(companyInfo);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenSize = MediaQuery.of(context).size;
      final maxDialogWidth = 800.0;
      final maxDialogHeight = 750.0;

      final dialogWidth = min(
        Responsive.isMobile(context)
            ? screenSize.width * 0.95
            : screenSize.width * 0.7,
        maxDialogWidth,
      );

      final dialogHeight = min(
        Responsive.isMobile(context)
            ? screenSize.height * 0.85
            : screenSize.height * 0.8,
        maxDialogHeight,
      );

      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          height: dialogHeight.toDouble(),
          width: dialogWidth.toDouble(),
          child: Padding(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company header with logo and name
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEFEFE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/sprout.svg",
                          height: 40,
                          colorFilter:
                              ColorFilter.mode(primaryColor, BlendMode.srcIn),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company?.name ?? companyInfo,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontSize:
                                        Responsive.isMobile(context) ? 20 : 24,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              company?.symbol != null
                                  ? '${company!.symbol}.${company.exchange == 'VFEX' ? 'VFEX' : 'ZW'}'
                                  : generateTicker(companyInfo),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Basic info chips
                  if (company != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(company.sector),
                          backgroundColor: Colors.grey[200],
                        ),
                        Chip(
                          label: Text('Est. ${company.founded}'),
                          backgroundColor: Colors.grey[200],
                        ),
                        Chip(
                          label: Text(company.dividend == 'Yes'
                              ? 'Dividend Paying'
                              : 'No Dividend'),
                          backgroundColor: company.dividend == 'Yes'
                              ? Colors.green[100]
                              : Colors.grey[200],
                        ),
                      ],
                    ),
                  SizedBox(height: 16),

                  // Company description
                  Text(
                    "About ${company?.name.split(' ').first ?? companyInfo.split(' ').first}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    company?.description ??
                        "${companyInfo} is a leading Zimbabwean company with operations in multiple sectors. "
                            "The company has established itself as a key player in its industry.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),

                  // Contact info if available
                  if (company?.website != null ||
                      company?.headquarters != null) ...[
                    Text(
                      "Company Details",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8),
                    if (company?.headquarters != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              company!.headquarters,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    if (company?.website != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: () => launchUrl(Uri.parse(company.website)),
                          child: Row(
                            children: [
                              Icon(Icons.link, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                company!.website,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                  ],

                  // Historical data table
                  SizedBox(height: 24),
                  Text(
                    "Historical Predictions",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  if (historicalData.isEmpty)
                    Text(
                      "No historical data available",
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: Responsive.isMobile(context) ? 24 : 48,
                        columns: [
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Predicted")),
                          DataColumn(label: Text("Actual")),
                          DataColumn(label: Text("Variance")),
                          DataColumn(label: Text("Direction")),
                        ],
                        rows: historicalData.map((entry) {
                          final isOver = entry.direction == 'over';
                          final varianceColor =
                              isOver ? Colors.red : Colors.green;
                          final directionText = isOver ? "OVER" : "UNDER";

                          return DataRow(
                            cells: [
                              DataCell(Text(entry.date)),
                              DataCell(Text(
                                "\$${entry.predictedClose.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              )),
                              DataCell(Text(
                                "\$${entry.actualClose.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              DataCell(Text(
                                "${entry.variancePercent.toStringAsFixed(2)}%",
                                style: TextStyle(
                                  color: varianceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOver
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    directionText,
                                    style: TextStyle(
                                      color: isOver ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context)
                    ? defaultPadding
                    : defaultPadding * 1.5,
                vertical: Responsive.isMobile(context)
                    ? defaultPadding / 2
                    : defaultPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            label: Text(
              "Close",
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.isMobile(context) ? 14 : 16,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showRemoveConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Removal'),
      content: Text('Are you sure you want to remove this item?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item removed')),
            );
          },
          child: Text('Remove', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void navigateToInvestScreen(BuildContext context) async {
  const url = 'https://ctrade.co.zw/';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch investment platform')),
    );
  }
}

void showDetailedChart(
    BuildContext context,
    String stockSymbol,
    List<ChartData> climateAdjustedData,
    List<ChartData> wclimateAdjustedData,
    List<PredictionChartData> historicalStockPrice) {
  int selectedSegment = 1; // Track the selected segment

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Detailed Chart for $stockSymbol",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomSlidingSegmentedControl<int>(
                      initialValue: 1,
                      padding: 20,
                      children: const {
                        1: Text(
                          'Previous Prediction',
                          style: TextStyle(color: Colors.black),
                        ),
                        2: Text(
                          'Future Prediction',
                          style: TextStyle(color: Colors.black),
                        ),
                      },
                      decoration: BoxDecoration(
                        color: Color(0xFFF4FAFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      thumbDecoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInToLinear,
                      onValueChanged: (v) {
                        setState(() {
                          selectedSegment = v;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                    child: selectedSegment == 1
                        ? MonthlyPredictionChart(
                            chartData: historicalStockPrice,
                          )

                        // SfCartesianChart(
                        //     zoomPanBehavior: ZoomPanBehavior(
                        //       enablePinching: true,
                        //       enableDoubleTapZooming: true,
                        //       enablePanning: true,
                        //       enableSelectionZooming: true,
                        //     ),
                        //     primaryXAxis: DateTimeAxis(
                        //       title: AxisTitle(text: 'Weeks'),
                        //       intervalType: DateTimeIntervalType.days,
                        //       interval: 7,
                        //       dateFormat: DateFormat('MMM dd'),
                        //     ),
                        //     primaryYAxis: NumericAxis(
                        //       numberFormat: NumberFormat.currency(
                        //         symbol: 'ZiG ',
                        //         decimalDigits: 2,
                        //       ),
                        //     ),
                        //     series: <CartesianSeries>[
                        //       // Historical actual prices
                        //       LineSeries<ChartData, DateTime>(
                        //         name: 'Actual Prices',
                        //         dataSource: historicalStockPrice,
                        //         xValueMapper: (ChartData data, _) => data.x,
                        //         yValueMapper: (ChartData data, _) => data.close,
                        //         color: Colors.green,
                        //         width: 2,
                        //         markerSettings: MarkerSettings(isVisible: true),
                        //       ),
                        //       // Past predictions
                        //       LineSeries<ChartData, DateTime>(
                        //         name: 'Past Predictions',
                        //         dataSource: historicalStockPrice,
                        //         xValueMapper: (ChartData data, _) => data.x,
                        //         yValueMapper: (ChartData data, _) => data.open,
                        //         color: Colors.blue,
                        //         width: 2,
                        //         markerSettings: MarkerSettings(isVisible: true),
                        //       ),
                        //       // Error range (difference between prediction and actual)
                        //       RangeColumnSeries<ChartData, DateTime>(
                        //         name: 'Prediction Error',
                        //         dataSource: historicalStockPrice,
                        //         xValueMapper: (ChartData data, _) => data.x,
                        //         lowValueMapper: (ChartData data, _) => data.low,
                        //         highValueMapper: (ChartData data, _) =>
                        //             data.high,
                        //         color: Colors.red.withOpacity(0.3),
                        //       ),
                        //     ],
                        //     tooltipBehavior: TooltipBehavior(enable: true),
                        //     legend: Legend(
                        //       isVisible: true,
                        //       position: LegendPosition.top,
                        //     ),
                        //   )

                        : SfCartesianChart(
                            legend: Legend(
                              isVisible: true,
                              position: LegendPosition.top,
                            ),
                            zoomPanBehavior: ZoomPanBehavior(
                              enablePinching: true,
                              enableDoubleTapZooming: true,
                              enablePanning: true,
                              enableSelectionZooming: true,
                              selectionRectBorderColor: Colors.red,
                              selectionRectColor: Colors.grey.withOpacity(0.2),
                            ),
                            primaryXAxis: DateTimeAxis(
                                title: AxisTitle(text: 'Weeks'),
                                intervalType: DateTimeIntervalType.days,
                                interval: 7,
                                majorGridLines:
                                    const MajorGridLines(width: 0.15),
                                dateFormat: DateFormat('MMM dd')),
                            primaryYAxis: NumericAxis(
                                minimum: 100,
                                maximum: 900,
                                interval: 100,
                                numberFormat: NumberFormat.currency(
                                    symbol: 'ZiG ',
                                    decimalDigits: 2,
                                    customPattern: '¤#,##0.00')),
                            series: <CartesianSeries>[
                              ColumnSeries<ChartData, DateTime>(
                                name: 'Closing Price',
                                dataSource: climateAdjustedData,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.close,
                                color:
                                    primaryColor, // Use your app's primary color
                                width: 0.5, // Adjust bar width (0.0 to 1.0)
                                spacing: 0.2,
                                markerSettings: MarkerSettings(
                                    isVisible: true), // Space between bars
                                borderRadius: BorderRadius.vertical(
                                  top:
                                      Radius.circular(4), // Rounded top corners
                                  // dataLabelSettings: DataLabelSettings(
                                  //     isVisible: true, // Show values on bars
                                  //     labelAlignment:
                                  //         ChartDataLabelAlignment.top,
                                  //     textStyle: TextStyle(fontSize: 10)),
                                ),
                              ),
                              ColumnSeries<ChartData, DateTime>(
                                name: 'Opening Price',
                                dataSource: wclimateAdjustedData,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.open,
                                markerSettings: MarkerSettings(isVisible: true),
                                color: const Color(
                                    0xFF2196F3), // Second series color
                                width: 0.5,
                                spacing: 0.2,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ],
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ))
              ]),
            ),
          );
        },
      );
    },
  );
}

class MonthlyPredictionChart extends StatelessWidget {
  final List<PredictionChartData> chartData;

  const MonthlyPredictionChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
        enableSelectionZooming: true,
      ),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Weeks'),
        intervalType: DateTimeIntervalType.days,
        interval: 7,
        dateFormat: DateFormat('MMM dd'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Price (ZiG)'),
        numberFormat: NumberFormat.currency(
          symbol: 'ZiG ',
          decimalDigits: 2,
        ),
      ),
      series: <CartesianSeries>[
        // Actual Prices
        ColumnSeries<PredictionChartData, DateTime>(
          name: 'Actual Price',
          dataSource: chartData,
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.actualPrice,
          color: Colors.green,
          width: 0.2,
          spacing: 0.2,
        ),
        // Normal Predictions
        ColumnSeries<PredictionChartData, DateTime>(
          name: 'Normal Prediction',
          dataSource: chartData,
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.normalPrediction,
          color: Colors.blue,
          width: 0.2,
          spacing: 0.2,
        ),
        // Climate Predictions
        ColumnSeries<PredictionChartData, DateTime>(
          name: 'Climate Prediction',
          dataSource: chartData,
          xValueMapper: (data, _) => data.date,
          yValueMapper: (data, _) => data.climatePrediction,
          color: Colors.orange,
          width: 0.2,
          spacing: 0.2,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x\npoint.y : point.series.name',
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
      ),
    );
  }
}
