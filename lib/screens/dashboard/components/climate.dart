import 'package:admin/constants.dart';
import 'package:admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package

import '../../../models/climate.dart';

class ClimateCard extends StatefulWidget {
  const ClimateCard({Key? key}) : super(key: key);

  @override
  _ClimateCardState createState() => _ClimateCardState();
}

class _ClimateCardState extends State<ClimateCard> {
  late Future<ClimateData> futureClimateData;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    int currentYear = now.year;
    futureClimateData = apiService.fetchClimateData(currentYear, currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFF4FAFF),
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Climate Data As Of"),
          Text(
            DateFormat("MMMM yyyy").format(DateTime.now()),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          FutureBuilder<ClimateData>(
            future: futureClimateData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Display shimmer effect while loading data
                return buildShimmer();
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return Center(child: Text("No data available"));
              }

              ClimateData data = snapshot.data!;
              return Column(
                children: [
                  buildClimateDataColumn(
                      "Temperature:",
                      "${data.averageTempC.toStringAsFixed(1)}°C",
                      Icon(
                        Icons.thermostat_rounded,
                        color: primaryColor,
                        size: 15,
                      )),
                  buildClimateDataColumn(
                      "Rainfall Anomaly:",
                      "${data.rainfallAnomalyMm.toStringAsFixed(1)} mm",
                      Icon(
                        Icons.cloudy_snowing,
                        color: primaryColor,
                        size: 15,
                      ))
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Shimmer effect widget for loading state
  Widget buildShimmer() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.thermostat_rounded,
                  color: Colors.grey[400],
                  size: 15,
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  height: 14.0,
                  width: 100.0,
                ),
              ],
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.cloudy_snowing,
                  color: Colors.grey[400],
                  size: 15,
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  height: 14.0,
                  width: 100.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column buildClimateDataColumn(String label, String value, Icon icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              icon,
              SizedBox(width: 8), // Spacing between icon and text
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
