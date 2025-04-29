import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/climate.dart';
import 'package:admin/screens/dashboard/components/stock_info.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
// import 'chart.dart';

class StockDetails extends StatelessWidget {
  // final StockInfo stockDetails;
  final String userId;
  const StockDetails({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Climate Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          ClimateCard(),

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
                onPressed: () => navigateToInvestScreen(context),
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
                onPressed: () => showRemoveConfirmation(context),
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
          ),

          StockInfoCard(
            userId: userId, // This could represent number of shares
          ),

          SizedBox(height: defaultPadding),
          // Row(
          //   children: [
          //     ElevatedButton.icon(
          //       style: TextButton.styleFrom(
          //         backgroundColor: primaryColor,
          //         padding: EdgeInsets.symmetric(
          //           horizontal: defaultPadding * 1.5,
          //           vertical:
          //               defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius:
          //               BorderRadius.circular(6.0), // Slightly rounded corners
          //         ),
          //       ),
          //       onPressed: () => navigateToInvestScreen(context),

          //       icon: Icon(
          //         Icons.arrow_outward_outlined,
          //         color: Colors.white,
          //       ),
          //       label: Text(
          //         "Invest",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //     SizedBox(width: defaultPadding),
          //     ElevatedButton.icon(
          //       style: TextButton.styleFrom(
          //         backgroundColor: Colors.red,
          //         padding: EdgeInsets.symmetric(
          //           horizontal: defaultPadding * 1.5,
          //           vertical:
          //               defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius:
          //               BorderRadius.circular(6.0), // Slightly rounded corners
          //         ),
          //       ),
          //       onPressed: () {},
          //       icon: Icon(
          //         Icons.delete,
          //         color: Colors.white,
          //       ),
          //       label: Text(
          //         "Remove",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
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
