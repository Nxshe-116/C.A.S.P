class PriceData {
  final double open;
  final double high;
  final double low;
  final double closingPrice;

  PriceData({
    required this.open,
    required this.high,
    required this.low,
    required this.closingPrice,
  });
}

class StockInfo {
  final String companyName;
  final String ticker;
  final double closingPrice;
  final double priceChange; // Positive for increase, negative for decrease
  final double climateImpactFactor;
  final List<PriceData> priceHistory; // List of PriceData
  final List<double>
      climateImpactHistory; // Daily climate impact factors for a week

  StockInfo({
    required this.companyName,
    required this.ticker,
    required this.closingPrice,
    required this.priceChange,
    required this.climateImpactFactor,
    required this.priceHistory,
    required this.climateImpactHistory,
  });
}

List<StockInfo> demoStockData = [
  StockInfo(
    companyName: "Tanganda Tea Company",
    ticker: "TANG",
    closingPrice: 150.45,
    priceChange: 1.5,
    climateImpactFactor: 0.9,
    priceHistory: [
      PriceData(open: 145.00, high: 150.00, low: 144.00, closingPrice: 150.45),
      PriceData(open: 148.50, high: 150.50, low: 146.00, closingPrice: 149.80),
      PriceData(open: 146.20, high: 148.20, low: 145.00, closingPrice: 147.70),
      PriceData(open: 147.70, high: 149.00, low: 146.50, closingPrice: 148.90),
      PriceData(open: 148.90, high: 151.00, low: 148.00, closingPrice: 151.20),
      PriceData(open: 151.20, high: 152.50, low: 150.50, closingPrice: 150.20),
      PriceData(open: 150.20, high: 151.70, low: 149.50, closingPrice: 149.80),
      PriceData(open: 149.80, high: 151.00, low: 148.50, closingPrice: 151.60),
      PriceData(open: 151.60, high: 152.00, low: 150.50, closingPrice: 150.00),
      PriceData(open: 150.00, high: 151.50, low: 149.00, closingPrice: 152.10),
    ],
    climateImpactHistory: [
      0.7, 0.8, 0.7, 0.9, 0.8, 0.7, 0.8, 0.7, 0.9, 0.8,
      0.9, 1.0, 0.8, 0.9, 1.0, 0.8, 0.9
    ],
  ),
  
  StockInfo(
    companyName: "Seed Co Limited",
    ticker: "SEED",
    closingPrice: 180.75,
    priceChange: -0.8,
    climateImpactFactor: 1.1,
    priceHistory: [
      PriceData(open: 177.50, high: 179.00, low: 176.00, closingPrice: 180.75),
      PriceData(open: 179.80, high: 180.50, low: 178.50, closingPrice: 179.80),
      PriceData(open: 182.10, high: 183.00, low: 181.50, closingPrice: 182.10),
      PriceData(open: 180.30, high: 181.00, low: 179.50, closingPrice: 180.30),
      PriceData(open: 182.70, high: 183.50, low: 181.20, closingPrice: 183.10),
      PriceData(open: 183.10, high: 184.00, low: 182.50, closingPrice: 181.00),
      PriceData(open: 181.00, high: 183.00, low: 180.00, closingPrice: 183.50),
      PriceData(open: 183.50, high: 184.50, low: 182.00, closingPrice: 182.60),
      PriceData(open: 182.60, high: 184.00, low: 181.00, closingPrice: 184.00),
    ],
    climateImpactHistory: [
      1.0, 1.1, 1.0, 1.2, 1.1, 1.0, 1.2, 1.0, 1.1, 1.0,
      1.1, 1.0, 1.1, 1.2, 1.1, 1.0, 1.1
    ],
  ),
  
  StockInfo(
    companyName: "TSL Limited",
    ticker: "TSL",
    closingPrice: 95.60,
    priceChange: 0.3,
    climateImpactFactor: 0.7,
    priceHistory: [
      PriceData(open: 94.00, high: 95.00, low: 93.50, closingPrice: 95.60),
      PriceData(open: 95.10, high: 96.00, low: 94.00, closingPrice: 95.10),
      PriceData(open: 94.50, high: 95.00, low: 93.80, closingPrice: 94.20),
      PriceData(open: 94.20, high: 95.00, low: 93.00, closingPrice: 94.30),
      PriceData(open: 95.30, high: 96.00, low: 94.50, closingPrice: 95.80),
      PriceData(open: 94.80, high: 95.50, low: 94.10, closingPrice: 95.00),
      PriceData(open: 95.60, high: 96.50, low: 94.80, closingPrice: 94.70),
      PriceData(open: 94.70, high: 95.50, low: 93.80, closingPrice: 95.00),
      PriceData(open: 95.00, high: 96.00, low: 94.00, closingPrice: 95.20),
    ],
    climateImpactHistory: [
      0.7, 0.6, 0.8, 0.7, 0.7, 0.8, 0.6, 0.7, 0.8, 0.6,
      0.7, 0.8, 0.7, 0.6, 0.8, 0.7, 0.8
    ],
  ),
  
  StockInfo(
    companyName: "Hippo Valley Estates Limited",
    ticker: "HIPO",
    closingPrice: 220.80,
    priceChange: 2.1,
    climateImpactFactor: 0.8,
    priceHistory: [
      PriceData(open: 216.00, high: 218.00, low: 215.00, closingPrice: 220.80),
      PriceData(open: 218.30, high: 219.00, low: 217.00, closingPrice: 218.30),
      PriceData(open: 215.40, high: 217.50, low: 214.50, closingPrice: 219.80),
      PriceData(open: 219.80, high: 221.50, low: 218.00, closingPrice: 220.00),
      PriceData(open: 218.20, high: 220.00, low: 217.00, closingPrice: 221.00),
      PriceData(open: 221.00, high: 222.00, low: 220.00, closingPrice: 221.50),
      PriceData(open: 217.60, high: 219.00, low: 216.00, closingPrice: 219.50),
      PriceData(open: 220.10, high: 222.00, low: 219.00, closingPrice: 221.00),
      PriceData(open: 219.50, high: 221.00, low: 218.00, closingPrice: 222.30),
    ],
    climateImpactHistory: [
      0.8, 0.9, 0.8, 0.7, 0.8, 0.7, 0.8, 0.7, 0.8, 0.8,
      0.9, 0.7, 0.8, 0.9, 0.8, 0.7, 0.8
    ],
  ),
];
