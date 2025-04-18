import 'package:admin/models/tickers.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import 'package:admin/models/predictions.dart';

class StockInfoCard extends StatelessWidget {
  const StockInfoCard({
    Key? key,
    required this.info,
    required this.uid,
    this.realTimeData,
    this.isLoading = false, // Add a loading state
  }) : super(key: key);

  final String info;
  final String uid;
  final RealTimePrediction? realTimeData;
  final bool isLoading; // Indicates if data is loading

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Color(0xFFF4FAFF),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(defaultPadding * 0.75),
                height: Responsive.isMobile(context)
                    ? 36.h
                    : 36.h, // Adjust height for mobile
                width: Responsive.isMobile(context)
                    ? 35.w
                    : 10.w, // Adjust width for mobile
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFEFE),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  "assets/icons/sprout.svg",
                  colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                  fit: BoxFit.fill, // Ensure the SVG fits inside the container
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey),
                color: Colors
                    .white, // Set the background color of the dropdown to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Rounded corners for the dropdown
                ),
                offset: Offset(0, 40),
                onSelected: (String value) {
                  handleMenuSelection(value, context, info, uid);
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
              )
            ],
          ),
          // Display stock name and symbol
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100,
                height: 16,
                color: Colors.white,
              ),
            )
          else
            Text(
              info,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.grey[850]),
            ),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 50,
                height: 12,
                color: Colors.white,
              ),
            )
          else
            Text(
              generateTicker(info),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Colors.black54),
            ),

          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 80,
                height: 16,
                color: Colors.white,
              ),
            )
          else if (realTimeData != null)
            Row(
              children: [
                Text("\$${realTimeData!.currentPrediction.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(width: defaultPadding),
                Text(
                  realTimeData != null
                      ? "${((realTimeData!.currentPrediction - realTimeData!.previousPrediction) / realTimeData!.previousPrediction * 100).toStringAsFixed(2)}%"
                      : "--",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: realTimeData != null
                            ? (realTimeData!.currentPrediction >=
                                    realTimeData!.previousPrediction
                                ? Colors.green
                                : Colors.red)
                            : Colors.grey,
                      ),
                )
              ],
            )
          else
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

void handleMenuSelection(
    String value, BuildContext context, String companyInfo, String uid) {
  switch (value) {
    case 'company_info':
      showDataDialog(context, companyInfo, uid);
      break;
    case 'remove':
      showRemoveConfirmation(context);
      break;
    case 'invest':
      navigateToInvestScreen(context);
      break;
  }
}

void showDataDialog(
  BuildContext context,
  String companyInfo,
  String uid,
) {
  // Sample historical data - replace with your actual data
  final List<Map<String, dynamic>> historicalData = [
    {'year': '2023', 'revenue': '2.5B', 'profit': '450M', 'dividend': '1.20'},
    {'year': '2022', 'revenue': '2.3B', 'profit': '420M', 'dividend': '1.10'},
    {'year': '2021', 'revenue': '2.1B', 'profit': '380M', 'dividend': '1.00'},
    {'year': '2020', 'revenue': '1.9B', 'profit': '350M', 'dividend': '0.90'},
    {'year': '2019', 'revenue': '1.7B', 'profit': '320M', 'dividend': '0.85'},
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          final dialogWidth =
              Responsive.isMobile(context) ? screenWidth * 0.9 : 600;
          final dialogHeight =
              Responsive.isMobile(context) ? screenHeight * 0.8 : 600;

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
                padding:
                    EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company name and ticker
                      Text(
                        companyInfo,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontSize: Responsive.isMobile(context) ? 20 : 24,
                            ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        generateTicker(companyInfo),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: primaryColor,
                            ),
                      ),
                      SizedBox(height: 16),

                      // Company description
                      Text(
                        "About ${companyInfo.split(' ').first}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "${companyInfo} is a leading agricultural company specializing in sustainable farming solutions. "
                        "With over 20 years in the industry, we've pioneered innovative crop technologies that increase "
                        "yields while reducing environmental impact. Our operations span across multiple continents, "
                        "serving both commercial and small-scale farmers.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 24),

                      // Historical data table
                      Text(
                        "Historical Financials",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 12),

                      // Scrollable table container
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 40,
                            headingRowHeight: 40,
                            columns: const [
                              DataColumn(
                                  label: Text('Year',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Revenue',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Profit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Dividend',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: historicalData.map((data) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(data['year'])),
                                  DataCell(Text(data['revenue'])),
                                  DataCell(Text(data['profit'])),
                                  DataCell(Text(data['dividend'])),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
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
            // Perform removal logic here
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

void navigateToInvestScreen(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => InvestScreen()),
  // );
}
