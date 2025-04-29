import 'dart:math';

import 'package:admin/models/company.dart';
import 'package:admin/models/tickers.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
import 'package:admin/models/predictions.dart';

class StockInfoCard extends StatefulWidget {
  const StockInfoCard({
    Key? key,
    required this.info,
    required this.uid,
    this.realTimeData,
    this.isLoading = false,
  }) : super(key: key);

  final String info;
  final String uid;
  final RealTimePrediction? realTimeData;
  final bool isLoading;

  @override
  State<StockInfoCard> createState() => _StockInfoCardState();
}

class _StockInfoCardState extends State<StockInfoCard> {
  final ApiService apiService = ApiService();
  List<PredictionEntry> historicalData = [];
  String? errorMessage;
  bool isLoading = true;
  int _historyRetryCount = 0;
  final int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    //print('initState called - fetching data for ${widget.info}');
    fetchHistoricalPredictions(widget.info);
  }

  void _handleError(String message, Exception e) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
    debugPrint('Error: $message, Exception: $e');
  }

  Future<void> fetchHistoricalPredictions(String symbol) async {
    try {
      final response = await apiService.fetchHistoricalPredictions(symbol);

      if (!mounted) return;

      setState(() {
        // Convert the API response to your model
        historicalData = response.historicalPredictions;

        errorMessage = null;
      });
    } catch (e) {
      if (_historyRetryCount < _maxRetries) {
        _historyRetryCount++;
        await Future.delayed(Duration(seconds: 1));
        await fetchHistoricalPredictions(symbol);
      } else {
        _handleError(
            'Failed to load historical data for $symbol', e as Exception);
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
                height: Responsive.isMobile(context) ? 36.h : 36.h,
                width: Responsive.isMobile(context) ? 35.w : 10.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFEFE),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  "assets/icons/sprout.svg",
                  colorFilter:
                      const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                offset: Offset(0, 40),
                onSelected: (String value) {
                  handleMenuSelection(
                      value, context, widget.info, widget.uid, historicalData);
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

          // Error message display
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          // Stock name and symbol
          if (widget.isLoading)
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
              widget.info,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.grey[850]),
            ),

          if (widget.isLoading)
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
              generateTicker(widget.info),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Colors.black54),
            ),

          if (widget.isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 80,
                height: 16,
                color: Colors.white,
              ),
            )
          else if (widget.realTimeData != null)
            Row(
              children: [
                Text(
                    "\$${widget.realTimeData!.currentPrediction.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(width: defaultPadding),
                Text(
                  "${((widget.realTimeData!.currentPrediction - widget.realTimeData!.previousPrediction) / widget.realTimeData!.previousPrediction * 100).toStringAsFixed(2)}%",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.realTimeData!.currentPrediction >=
                                widget.realTimeData!.previousPrediction
                            ? Colors.green
                            : Colors.red,
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
                        columnSpacing: 120,
                        columns: [
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Prediction")),
                          DataColumn(label: Text("Actual")),
                          DataColumn(label: Text("Change")),
                        ],
                        rows: historicalData.map((data) {
                          double change =
                              data.actualClose - data.predictedClose;
                          double percentageChange =
                              (change / data.predictedClose) * 100;
                          return DataRow(cells: [
                            DataCell(Text(data.date)),
                            DataCell(Text(
                                "\$${data.predictedClose.toStringAsFixed(2)}")),
                            DataCell(Text(
                              "\$${data.actualClose.toStringAsFixed(2)}",
                            )),
                            DataCell(Text(
                              "${percentageChange.toStringAsFixed(2)}%",
                            )),
                          ]);
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
