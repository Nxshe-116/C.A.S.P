import 'package:admin/models/my_files.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';

import 'components/recent_files.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(text: "Dashboard"),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(),
                      SizedBox(height: defaultPadding),
                      RecentFiles(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        StockDetails(
                          stockDetails: StockInfo(
                            companyName: "Seed Co Limited",
                            ticker: "SEED",
                            closingPrice: 180.75,
                            priceChange: -0.8,
                            climateImpactFactor: 1.1,
                            priceHistory: [
                              182.30,
                              181.50,
                              181.00,
                              180.00,
                              179.80,
                              180.75,
                              180.75
                            ],
                            climateImpactHistory: [
                              1.0,
                              1.0,
                              1.1,
                              1.1,
                              1.1,
                              1.1,
                              1.1
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
                        companyName: "Seed Co Limited",
                        ticker: "SEED",
                        closingPrice: 180.75,
                        priceChange: -0.8,
                        climateImpactFactor: 1.1,
                        priceHistory: [
                          182.30,
                          181.50,
                          181.00,
                          180.00,
                          179.80,
                          180.75,
                          180.75
                        ],
                        climateImpactHistory: [
                          1.0,
                          1.0,
                          1.1,
                          1.1,
                          1.1,
                          1.1,
                          1.1
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
