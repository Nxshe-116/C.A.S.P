class Company {
  final String name;
  final String symbol;
  final String exchange;
  final String sector;
  final String founded;
  final String website;
  final String headquarters;
  final String dividend;
  final String description;

  Company({
    required this.name,
    required this.symbol,
    required this.exchange,
    required this.sector,
    required this.founded,
    required this.website,
    required this.headquarters,
    required this.dividend,
    required this.description,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      exchange: json['exchange'] ?? 'ZSE',
      sector: json['sector'] ?? '',
      founded: json['founded'] ?? '',
      website: json['website'] ?? '',
      headquarters: json['headquarters'] ?? '',
      dividend: json['dividend'] ?? 'No',
      description: json['description'] ?? '',
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'exchange': exchange,
      'sector': sector,
      'founded': founded,
      'website': website,
      'headquarters': headquarters,
      'dividend': dividend,
      'description': description,
    };
  }
}

Company? getCompany(String name) {
  final companies = <String, Company>{
    'DAIRIBOARD': Company(
      name: 'Dairibord Holdings',
      symbol: 'DZL',
      exchange: 'ZSE',
      sector: 'Food & Beverages',
      founded: '1952',
      website: 'https://dairibord.com',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'Yes',
      description:
          'A leading Zimbabwean manufacturer of dairy and non-dairy products, including milk, beverages, and foods.',
    ),
    'HWANGE COALIARY': Company(
      name: 'Hwange Colliery Company',
      symbol: 'HCCL',
      exchange: 'ZSE',
      sector: 'Mining',
      founded: '1899',
      website: 'https://www.hwangecolliery.co.zw',
      headquarters: 'Hwange, Zimbabwe',
      dividend: 'No',
      description:
          'Engaged in coal mining, processing, and marketing, supplying coal to various sectors like energy and industry.',
    ),
    'MASIMBA HOLDINGS': Company(
      name: 'Masimba Holdings',
      symbol: 'MSHL',
      exchange: 'ZSE',
      sector: 'Construction & Engineering',
      founded: '1960s',
      website: 'https://www.masimbagroup.com',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'Yes',
      description:
          'A diversified contracting and industrial group with strong operations in construction and engineering services.',
    ),
    'NATIONAL FOODS': Company(
      name: 'National Foods',
      symbol: 'NTFD',
      exchange: 'VFEX',
      sector: 'Consumer Goods',
      founded: '1920',
      website: 'https://www.nationalfoods.co.zw',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'Yes',
      description:
          'One of Zimbabwe\'s largest food manufacturers, known for flour, maize meal, rice, and stockfeeds.',
    ),
    'STAR AFRICA': Company(
      name: 'StarAfrica Corporation',
      symbol: 'SACL',
      exchange: 'ZSE',
      sector: 'Consumer Staples',
      founded: '1940s',
      website: 'http://www.starafricacorporation.com',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'No',
      description:
          'Focused on sugar refining, manufacturing, and distribution in local and regional markets.',
    ),
    'SEEDCO': Company(
      name: 'Seed Co Limited',
      symbol: 'SEED',
      exchange: 'ZSE',
      sector: 'Agriculture',
      founded: '1940s',
      website: 'https://www.seedcogroup.com',
      headquarters: 'Stapleford, Zimbabwe',
      dividend: 'Yes',
      description:
          'Africa’s leading seed company, producing and marketing certified crop seeds for cereals and oil crops.',
    ),
    'SIMBISA': Company(
      name: 'Simbisa Brands',
      symbol: 'SIM',
      exchange: 'ZSE',
      sector: 'Hospitality / Quick Service Restaurants',
      founded: '2015',
      website: 'https://www.simbisabrands.com',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'Yes',
      description:
          'Operates Quick Service Restaurant brands including Chicken Inn, Pizza Inn, Bakers Inn, and Creamy Inn.',
    ),
    'TANGANDA': Company(
      name: 'Tanganda Tea Company',
      symbol: 'TANG',
      exchange: 'ZSE',
      sector: 'Agriculture / Beverages',
      founded: '1925',
      website: 'https://www.tanganda.co.zw',
      headquarters: 'Mutare, Zimbabwe',
      dividend: 'Yes',
      description:
          'Zimbabwe’s largest tea producer, also active in macadamia nuts, avocados, and bottled water.',
    ),
    'TSL': Company(
      name: 'TSL Limited',
      symbol: 'TSL',
      exchange: 'ZSE',
      sector: 'Logistics / Agriculture',
      founded: '1957',
      website: 'https://www.tsl.co.zw',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'Yes',
      description:
          'Provides auctioning, logistics, agro-supplies, printing, and packaging services.',
    ),
    'CFI HOLDINGS': Company(
      name: 'CFI Holdings',
      symbol: 'CFI',
      exchange: 'ZSE',
      sector: 'Agro-industrial',
      founded: '1908',
      website: 'https://www.cfigroup.co.zw',
      headquarters: 'Harare, Zimbabwe',
      dividend: 'No',
      description:
          'An agro-industrial group involved in poultry, retail, stockfeeds, and property investment.',
    ),
    'ARIS': Company(
      name: 'Ariston Holdings',
      symbol: 'ARIS',
      exchange: 'ZSE',
      sector: 'Agriculture / Horticulture',
      founded: '1950s',
      website: 'https://www.aristonholdings.co.zw',
      headquarters: 'Zimbabwe',
      dividend: 'Yes',
      description:
          'Produces tea, macadamia nuts, bananas, potatoes, poultry, and other horticultural products.',
    ),
  };

  return companies[name.toUpperCase()];
}
