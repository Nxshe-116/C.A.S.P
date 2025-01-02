import 'package:admin/models/my_files.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../constants.dart';

class RecentFiles extends StatefulWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  StockInfo? selectedStock;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Watchlist",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: defaultPadding),
          // Use Container or SizedBox instead of Expanded
          SizedBox(
            height: 300, // Set a specific height for the ListView
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    shrinkWrap:
                        true, // This can be omitted when using a fixed height
                    itemCount: demoStockData.length,
                    itemBuilder: (context, index) {
                      final stock = demoStockData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: StockListTile(
                          stockName: stock.companyName,
                          stockTicker: stock.ticker,
                          currentPrice: stock.closingPrice.toString(),
                          priceChange: stock.priceChange > 0
                              ? "+${stock.priceChange}%"
                              : "${stock.priceChange}%",
                          press: () {
                            setState(() {
                              selectedStock = stock; // Set the selected stock
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      //  color: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: ChartWidget(stock: selectedStock),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Your custom StockListTile widget
class StockListTile extends StatelessWidget {
  final String stockName, stockTicker, currentPrice, priceChange;
  final VoidCallback press;

  const StockListTile({
    Key? key,
    required this.stockName,
    required this.stockTicker,
    required this.currentPrice,
    required this.priceChange,
    required this.press,
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
        subtitle: Text(stockTicker),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("\$$currentPrice"),
            Text(
              priceChange,
              style: TextStyle(
                color: priceChange.contains('+') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        onTap: press,
      ),
    );
  }
}

// Your custom ChartWidget to display stock data
// class ChartWidget extends StatelessWidget {
//   final StockInfo? stock;

//   const ChartWidget({Key? key, this.stock}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (stock == null) {
//       return Center(child: Text("Select a stock to see its chart."));
//     }

//     // Example data to display. Replace with actual chart rendering logic.
//     return Center(
//       child: Column(
//         children: [
//           Text(
//             "Chart for ${stock!.companyName} - Price: \$${stock!.closingPrice}",
//             style: TextStyle(color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ChartWidget extends StatelessWidget {
  final StockInfo? stock;

  const ChartWidget({Key? key, this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SalesData> priceChartData = [];
    List<SalesData> climateImpactChartData = [];

    if (stock != null) {
      // Populate the price chart data based on the selected stock
      for (int i = 0; i < stock!.priceHistory.length; i++) {
        priceChartData.add(SalesData(
            DateTime.now().subtract(Duration(
                days: (stock!.priceHistory.length - i - 1) *
                    30)), // Adjusted to monthly intervals
            stock!.priceHistory[i]));
        climateImpactChartData.add(SalesData(
            DateTime.now().subtract(Duration(
                days: (stock!.climateImpactHistory.length - i - 1) * 30)),
            stock!.climateImpactHistory[i]));
      }
    }

    return Container(
      height: 200, // Set height for the chart
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          intervalType: DateTimeIntervalType.months,
          interval: 1, // Set to one month intervals
          majorGridLines: const MajorGridLines(width: 0),
        ),
        series: <CartesianSeries>[
          // Line series for price history
          LineSeries<SalesData, DateTime>(
            name: 'Price',
            dataSource: priceChartData,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
          ),
          // Line series for climate impact history
          LineSeries<SalesData, DateTime>(
            name: 'Climate Impact',
            dataSource: climateImpactChartData,
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
            color: Colors.green,
          ),
        ],
      //  legend: Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
