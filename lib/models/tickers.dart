import 'dart:math';

// Predefined tickers for known companies with exchange suffixes
Map<String, String> predefinedTickers = {
  // Agricultural Companies
  "Ariston Holdings": "ARIS.ZW",
  "Border Timbers": "BORD.ZW",
  "Cafca": "CAFCA.ZW",
  "Dairiboard Holdings": "DZL.ZW",
  "Dairiboard": "DZL.ZW",
  "Hippo Valley Estates": "HIPPO.ZW",
  "National Foods Holdings": "NTFD.ZW",
  "Seed Co International": "SCIL.VFEX", // VFEX
  "Seed Co Limited": "SEED.ZW", // ZSE
  "Simbisa Brands": "SIM.ZW",
  "Simbisa ": "SIM.ZW",
  "Star Africa Corporation": "SACL.ZW",
  "Star Africa": "SACL.ZW",
  "TSL Limited": "TSL.ZW",
  "Masimba Holdings": "MSHL.ZW", // Official ZSE ticker for Masimba
  "Masimba": "MSHL.ZW", // Alternate name
  "National Foods": "NTFD.ZW",

  "Natfoods": "NTFD.ZW", // Common colloquial name
  "NATIONAL FOODS": "NTFD.ZW", // Uppercase variant

  // Related Agribusiness Companies
  "Innscor Africa": "INN.ZW", // Parent company of National Foods
  "Proplastics": "PROP.ZW", // Irrigation equipment
  "Zimplow Holdings": "ZIMLOW.ZW", // Farm implements

  // Additional VFEX Listings
  "Padenga Holdings": "PAD.VFEX", // Crocodile farming (VFEX)

  // Forestry Companies
  "Timbers Holdings": "TIMB.ZW",

  // Beverage Companies (agricultural inputs)
  "Delta Corporation": "DLTA.ZW", // Brewing/agricultural inputs
  "African Distillers": "AFDS.ZW",
};

String generateTicker(String companyName) {
  // First try exact match
  if (predefinedTickers.containsKey(companyName)) {
    return predefinedTickers[companyName]!;
  }

  // Try case-insensitive match
  final lowerName = companyName.toLowerCase();
  for (final entry in predefinedTickers.entries) {
    if (entry.key.toLowerCase() == lowerName) {
      return entry.value;
    }
  }

  // Try partial match (if companyName contains a predefined name)
  for (final entry in predefinedTickers.entries) {
    if (companyName.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  // Generate a ticker if no predefined match found
  List<String> words =
      companyName.split(' ').where((word) => word.isNotEmpty).toList();
  String ticker = '';

  if (words.isEmpty) {
    return 'UNKNOWN.ZW';
  } else if (words.length == 1) {
    // Take the first 3-4 letters of a single-word name
    ticker = words[0].substring(0, min(4, words[0].length)).toUpperCase();
  } else {
    // Take first letter of first two words, plus two more from the first word
    ticker = words[0].substring(0, min(2, words[0].length)).toUpperCase() +
        words
            .sublist(1)
            .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
            .join();
  }

  // Ensure ticker is 2-5 characters long
  ticker = ticker.substring(0, min(5, max(2, ticker.length)));

  // Default to ZSE (.ZW suffix) for generated tickers
  return '$ticker.ZW';
}

// Example usage
void main() {
  final companies = [
    "Ariston Holdings",
    "Dairibord Holdings",
    "Seed Co International",
    "Padenga Holdings",
    "New Agricultural Co",
    "Zimbabwe Farming Ltd",
    "AFRICAN DISTILLERS", // Test case insensitivity
    "simbisa brands", // Test case insensitivity
    "Unknown Company",
    "", // Test empty input
  ];

  for (final company in companies) {
    print("$company → ${generateTicker(company)}");
  }
}
