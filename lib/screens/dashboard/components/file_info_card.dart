import 'package:admin/models/my_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class StockInfoCard extends StatelessWidget {
  const StockInfoCard({
    Key? key,
    required this.info,
  }) : super(key: key);

  final StockInfo info;

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
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFEFE),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  "assets/icons/sprout.svg",
                  colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          // Display stock name and symbol
          Text(
            info.companyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.grey[850]),
          ),
          Text(
            info.ticker,
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: Colors.black54),
          ),
          // Display stock price

          //  Theme.of(context)
          //           .textTheme
          //           .headlineSmall!
          //           .copyWith(color: Colors.white),

          Row(
            children: [
              Text("\$${info.closingPrice.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18)),
              // ProgressLine(
              //   color: info.color,
              //   percentage: (info.percentageChange! * 100)
              //       .toInt(), // Convert percentage change
              // ),
              SizedBox(width: defaultPadding),
              Text(
                "${info.priceChange > 0 ? "+" : ""}${info.priceChange.toStringAsFixed(2)}%",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: info.priceChange > 0 ? Colors.green : Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class ProgressLine extends StatelessWidget {
//   const ProgressLine({
//     Key? key,
//     this.color = primaryColor,
//     required this.percentage,
//   }) : super(key: key);

//   final Color? color;
//   final int? percentage;

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(
//         maxWidth: double.infinity, // Provide max width constraint
//         minHeight: 5,
//         maxHeight: 5,
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) => Stack(
//           children: [
//             Container(
//               width: constraints.maxWidth, // Full width as per constraints
//               height: 5,
//               decoration: BoxDecoration(
//                 color: color!.withOpacity(0.1),
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//               ),
//             ),
//             Container(
//               width: constraints.maxWidth * (percentage! / 100),
//               height: 5,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
