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
    this.realTimeData,
    this.isLoading = false, // Add a loading state
  }) : super(key: key);

  final String info;
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
                    ? 26.w
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
              Icon(Icons.more_vert, color: Colors.grey),
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
                Text("\$${realTimeData!.predictedClose.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(width: defaultPadding),
                Text(
                  "${realTimeData!.predictedClose > 0 ? "+" : ""}${realTimeData!.predictedClose.toStringAsFixed(2)}%",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: realTimeData!.predictedClose > 0
                          ? Colors.green
                          : Colors.red),
                ),
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
