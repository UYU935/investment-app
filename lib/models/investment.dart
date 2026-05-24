enum InvestmentSize { small, medium, large }

class Investment {
  final String id;
  final String name;
  final String nameEn;
  final int purchasePrice;
  final int monthlyIncome;
  final InvestmentSize size;
  final int stability;
  bool active;
  int troubleCount;
  bool incomeSuspended;
  bool incomeHalved;

  Investment({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.purchasePrice,
    required this.monthlyIncome,
    required this.size,
    required this.stability,
    this.active = true,
    this.troubleCount = 0,
    this.incomeSuspended = false,
    this.incomeHalved = false,
  });

  String localizedName(String locale) => locale == 'ja' ? name : nameEn;

  int get sellPrice {
    switch (size) {
      case InvestmentSize.small:
        return (purchasePrice * 0.8).round();
      case InvestmentSize.medium:
        return (purchasePrice * 0.7).round();
      case InvestmentSize.large:
        return (purchasePrice * 0.6).round();
    }
  }

  int get sellPercent {
    switch (size) {
      case InvestmentSize.small:
        return 80;
      case InvestmentSize.medium:
        return 70;
      case InvestmentSize.large:
        return 60;
    }
  }

  String get sizeKey {
    switch (size) {
      case InvestmentSize.small:
        return 'small';
      case InvestmentSize.medium:
        return 'medium';
      case InvestmentSize.large:
        return 'large';
    }
  }

  Investment copyWith({
    bool? active,
    int? troubleCount,
    bool? incomeSuspended,
    bool? incomeHalved,
  }) {
    return Investment(
      id: id,
      name: name,
      nameEn: nameEn,
      purchasePrice: purchasePrice,
      monthlyIncome: monthlyIncome,
      size: size,
      stability: stability,
      active: active ?? this.active,
      troubleCount: troubleCount ?? this.troubleCount,
      incomeSuspended: incomeSuspended ?? this.incomeSuspended,
      incomeHalved: incomeHalved ?? this.incomeHalved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameEn': nameEn,
        'purchasePrice': purchasePrice,
        'monthlyIncome': monthlyIncome,
        'size': size.index,
        'stability': stability,
        'active': active,
        'troubleCount': troubleCount,
        'incomeSuspended': incomeSuspended,
        'incomeHalved': incomeHalved,
      };

  factory Investment.fromJson(Map<String, dynamic> json) => Investment(
        id: json['id'],
        name: json['name'],
        nameEn: json['nameEn'] ?? json['name'],
        purchasePrice: json['purchasePrice'],
        monthlyIncome: json['monthlyIncome'],
        size: InvestmentSize.values[json['size']],
        stability: json['stability'],
        active: json['active'] ?? true,
        troubleCount: json['troubleCount'] ?? 0,
        incomeSuspended: json['incomeSuspended'] ?? false,
        incomeHalved: json['incomeHalved'] ?? false,
      );
}
