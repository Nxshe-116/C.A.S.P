import 'package:admin/constants.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final String uid;

  // Sample data - replace with your actual data source
  final List<StockHistory> stockHistory = [
    StockHistory(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      action: 'Buy',
      shares: 10,
      price: 145.32,
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
    StockHistory(
      symbol: 'GOOGL',
      name: 'Alphabet Inc.',
      action: 'Sell',
      shares: 5,
      price: 2356.78,
      date: DateTime.now().subtract(Duration(days: 5)),
    ),
    StockHistory(
      symbol: 'TSLA',
      name: 'Tesla Inc.',
      action: 'Buy',
      shares: 3,
      price: 876.54,
      date: DateTime.now().subtract(Duration(days: 10)),
    )
  ];

  final List<StockHolding> currentHoldings = [
    StockHolding(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      shares: 15,
      avgPrice: 142.50,
      currentPrice: 145.32,
    ),
    StockHolding(
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      shares: 8,
      avgPrice: 245.67,
      currentPrice: 251.89,
    ),
  ];

  PortfolioScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
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
              text: "History",
              name: name,
              lastName: lastName,
            ),
            SizedBox(height: defaultPadding),

            // Current Holdings Section
            _buildSectionHeader('Current Holdings'),
            _buildHoldingsList(),
            SizedBox(height: defaultPadding),

            // Transaction History Section
            _buildSectionHeader('Transaction History'),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Symbol',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Company',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Shares',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Value',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Change',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Divider(height: 1),
          ...currentHoldings
              .map((holding) => _buildHoldingItem(holding))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(StockHolding holding) {
    final change = holding.currentPrice - holding.avgPrice;
    final changePercent = (change / holding.avgPrice) * 100;
    final isPositive = change >= 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(holding.symbol,
                  style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(holding.name)),
          Expanded(flex: 2, child: Text(holding.shares.toString())),
          Expanded(
              flex: 2,
              child: Text(
                  '\$${(holding.currentPrice * holding.shares).toStringAsFixed(2)}')),
          Expanded(
            flex: 2,
            child: Text(
              '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Symbol',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Action',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Shares',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Price',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Divider(height: 1),
          ...stockHistory.map((history) => _buildHistoryItem(history)).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(StockHistory history) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isBuy = history.action == 'Buy';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(dateFormat.format(history.date))),
          Expanded(
              flex: 2,
              child: Text(history.symbol,
                  style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 3,
            child: Text(
              history.action,
              style: TextStyle(
                color: isBuy ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(history.shares.toString())),
          Expanded(
              flex: 2, child: Text('\$${history.price.toStringAsFixed(2)}')),
          Expanded(
              flex: 2,
              child: Text(
                  '\$${(history.shares * history.price).toStringAsFixed(2)}')),
        ],
      ),
    );
  }
}

// Data models
class StockHistory {
  final String symbol;
  final String name;
  final String action; // 'Buy' or 'Sell'
  final int shares;
  final double price;
  final DateTime date;

  StockHistory({
    required this.symbol,
    required this.name,
    required this.action,
    required this.shares,
    required this.price,
    required this.date,
  });
}

class StockHolding {
  final String symbol;
  final String name;
  final int shares;
  final double avgPrice;
  final double currentPrice;

  StockHolding({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.avgPrice,
    required this.currentPrice,
  });
}
