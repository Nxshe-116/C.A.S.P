import 'dart:async';
import 'dart:io';

import 'package:admin/constants.dart';
import 'package:admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/climate.dart';

class ClimateCard extends StatefulWidget {
  const ClimateCard({Key? key}) : super(key: key);

  @override
  _ClimateCardState createState() => _ClimateCardState();
}

class _ClimateCardState extends State<ClimateCard> {
  late Future<ClimateData> futureClimateData;
  final ApiService apiService = ApiService();
  int _retryCount = 0;
  final int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _fetchClimateData();
  }

  void _fetchClimateData() {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);
    int currentYear = now.year;

    setState(() {
      futureClimateData =
          apiService.fetchClimateData(currentYear, currentMonth).then((data) {
        _retryCount = 0; // Reset retry count on success
        return data;
      }).catchError((error) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          // Retry after a delay
          Future.delayed(Duration(seconds: 2), _fetchClimateData);
        }
        throw error; // Re-throw the error to be caught by FutureBuilder
      });
    });
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
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmer();
              }

              // Error state
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error);
              }

              // No data state
              if (!snapshot.hasData) {
                return _buildNoDataState();
              }

              // Success state
              ClimateData data = snapshot.data!;
              return Column(
                children: [
                  _buildClimateDataColumn(
                    "Temperature:",
                    "${data.averageTempC.toStringAsFixed(1)}°C",
                    Icon(
                      Icons.thermostat_rounded,
                      color: primaryColor,
                      size: 15,
                    ),
                  ),
                  _buildClimateDataColumn(
                    "Rainfall Anomaly:",
                    "${data.rainfallAnomalyMm.toStringAsFixed(1)} mm",
                    Icon(
                      Icons.cloudy_snowing,
                      color: primaryColor,
                      size: 15,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
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
                  height: 14.0,
                  width: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                )
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
        if (_retryCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Retrying... (${_retryCount}/$_maxRetries)",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 40,
        ),
        SizedBox(height: 8),
        Text(
          "Failed to load climate data",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          _getUserFriendlyError(error),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _fetchClimateData,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            "Retry",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataState() {
    return Column(
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.blue,
          size: 40,
        ),
        SizedBox(height: 8),
        Text(
          "No climate data available",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _fetchClimateData,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            "Refresh",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is SocketException) {
      return "Network connection failed. Please check your internet connection.";
    } else if (error is TimeoutException) {
      return "Request timed out. The server is taking too long to respond.";
    } else if (error is HttpException) {
      return "Server error occurred . Please try again later.";
    } else if (error is FormatException) {
      return "Data format error. Please contact support.";
    }
    return "An unexpected error occurred. Please try again.";
  }

  Column _buildClimateDataColumn(String label, String value, Icon icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              icon,
              SizedBox(width: 8),
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
