import 'package:admin/models/my_files.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/stock_info.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'chart.dart';

class StockDetails extends StatelessWidget {
  final StockInfo stockDetails;
  const StockDetails({
    Key? key,
    required this.stockDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(), // You can update the chart to reflect stock market trends
          StockInfoCard(
            svgSrc: "assets/icons/trace.svg", // Update with a relevant icon
            title: "${stockDetails.companyName}- ${stockDetails.ticker}",
            amountOfShares:
                stockDetails.closingPrice, // Share price or another metric
            numOfShares: 1000000000, // This could represent number of shares
          ),
          SizedBox(height: defaultPadding),
          Row(
            children: [
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(6.0), // Slightly rounded corners
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_outward_outlined,
                  color: Colors.white,
                ),
                label: Text(
                  "Invest",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: defaultPadding),
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(6.0), // Slightly rounded corners
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                label: Text(
                  "Remove",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
