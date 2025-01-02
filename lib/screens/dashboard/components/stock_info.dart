import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class StockInfoCard extends StatelessWidget {
  const StockInfoCard({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.amountOfShares, // Updated parameter
    required this.numOfShares, // Updated parameter
  }) : super(key: key);

  final String title, svgSrc; //\final doRenamed
  final double amountOfShares;
  final int numOfShares; // Renamed

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        // border: Border.all(width: 2, color: const Color(0xFFF4FAFF)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  svgSrc,
                  color: Colors.green[300],
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "$numOfShares Shares", // Updated to reflect stocks
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              Text("${amountOfShares}"),

              // Updated to reflect stock amounts (like price)
            ],
          ),
          SizedBox(height: defaultPadding * 1.2),
          Text(
            "Seed Co Limited leads in crop production and seed research, delivering sustainable, high-quality seeds for diverse climates.",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: defaultPadding),
          Table(
            columnWidths: {
              0: FlexColumnWidth(2), // Label column width
              1: FlexColumnWidth(3), // Value column width
            },
            children: [
              TableRow(children: [
                Text("Ticker:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("SEED"),
              ]),
              TableRow(children: [
                Text("Closing Price:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("\$180.75"),
              ]),
              TableRow(children: [
                Text("Price Change:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("-0.8%"),
              ]),
              TableRow(children: [
                Text("Climate Impact Factor:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("1.1"),
              ]),
              TableRow(children: [
                Text("P/E Ratio:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("18.4"), // Example value
              ]),
              TableRow(children: [
                Text("Market Cap:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("\$4.5B"), // Example value
              ]),
              TableRow(children: [
                Text("Dividend Yield:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("2.3%"), // Example value
              ]),
            ],
          )
        ],
      ),
    );
  }
}
