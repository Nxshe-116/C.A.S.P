import 'package:admin/models/my_files.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';

import 'components/recent_files.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final String uid;

  const DashboardScreen({
    Key? key,
    required this.name,
    required this.lastName, required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              text: "Dashboard",
              name: name,
              lastName: lastName,
            ),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(uid:uid),
                      SizedBox(height: defaultPadding),
                      RecentFiles(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        StockDetails(
                          stockDetails: StockInfo(
                            companyName: "Tanganda Tea Company",
                            ticker: "TANG",
                            closingPrice: 150.45,
                            priceChange: 1.5,
                            climateImpactFactor: 0.9,
                            priceHistory: [
                              PriceData(
                                  open: 145.00,
                                  high: 150.00,
                                  low: 144.00,
                                  closingPrice: 150.45),
                              PriceData(
                                  open: 148.50,
                                  high: 150.50,
                                  low: 146.00,
                                  closingPrice: 149.80),
                              // Add similar data for other entries
                            ],
                            climateImpactHistory: [
                              0.7,
                              0.8,
                              0.7,
                              0.9,
                              0.8,
                              0.7,
                              0.8,
                              0.7,
                              0.9,
                              0.8,
                              0.9,
                              1.0,
                              0.8,
                              0.9,
                              1.0,
                              0.8,
                              0.9
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: StockDetails(
                      stockDetails: StockInfo(
                        companyName: "Tanganda Tea Company",
                        ticker: "TANG",
                        closingPrice: 150.45,
                        priceChange: 1.5,
                        climateImpactFactor: 0.9,
                        priceHistory: [
                          PriceData(
                              open: 145.00,
                              high: 150.00,
                              low: 144.00,
                              closingPrice: 150.45),
                          PriceData(
                              open: 148.50,
                              high: 150.50,
                              low: 146.00,
                              closingPrice: 149.80),
                          // Add similar data for other entries
                        ],
                        climateImpactHistory: [
                          0.7,
                          0.8,
                          0.7,
                          0.9,
                          0.8,
                          0.7,
                          0.8,
                          0.7,
                          0.9,
                          0.8,
                          0.9,
                          1.0,
                          0.8,
                          0.9,
                          1.0,
                          0.8,
                          0.9
                        ],
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
