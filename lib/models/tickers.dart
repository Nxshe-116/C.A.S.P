import 'dart:math';

// Predefined tickers for known companies
Map<String, String> predefinedTickers = {
  "Dairiboard": "DSL",
  "Simbisa": "SIM",
  "Star Africa": "SACL",
  "TSL": "TSL",
  "National Foods": "NFL",
};

String generateTicker(String companyName) {
  // Check if the company has a predefined ticker
  if (predefinedTickers.containsKey(companyName)) {
    return '${predefinedTickers[companyName]}.ZW';
  }

  List<String> words = companyName.split(' '); // Split by spaces if any
  String ticker = '';

  if (words.length == 1) {
    // Take the first 3-4 letters of a single-word name
    ticker = companyName.substring(0, min(4, companyName.length)).toUpperCase();
  } else {
    // Take first letter of first two words, plus two more from the first word
    ticker = words[0].substring(0, min(2, words[0].length)).toUpperCase() +
        words.sublist(1).map((word) => word[0].toUpperCase()).join();
  }

  return '$ticker.ZW';
}

