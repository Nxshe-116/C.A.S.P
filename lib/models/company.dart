class Company {
  final String symbol;
  final String name;
 

  Company({
    required this.symbol,
    required this.name,
   
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      symbol: json['symbol'],
      name: json['name'], // Assuming 'name' is part of the API response
     
    );
  }
}