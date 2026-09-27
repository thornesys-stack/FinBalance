class HomeModel {
  final String startDate;
  final String endDate;

  final double balance;
  final double income;
  final double expense;

  final List<HomeCategory> categories;

  final String aiSummary;

  const HomeModel({
    required this.startDate,
    required this.endDate,
    required this.balance,
    required this.income,
    required this.expense,
    required this.categories,
    required this.aiSummary,
  });

  factory HomeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final period =
        json['period'] as Map<String, dynamic>? ?? {};

    final categoriesJson =
        json['categories'] as List<dynamic>? ?? [];

    return HomeModel(
      startDate: period['startDate']?.toString() ?? '',
      endDate: period['endDate']?.toString() ?? '',
      balance: _toDouble(json['balance']),
      income: _toDouble(json['income']),
      expense: _toDouble(json['expense']),
      categories: categoriesJson
          .whereType<Map<String, dynamic>>()
          .map(HomeCategory.fromJson)
          .toList(),
      aiSummary: json['aiSummary']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  HomeCategory? findCategory(String name) {
    for (final category in categories) {
      if (category.name == name) {
        return category;
      }
    }

    return null;
  }

  double getCategoryAmount(String name) {
    return findCategory(name)?.amount ?? 0.0;
  }
}


class HomeCategory {
  final String name;
  final double amount;
  final String icon;

  const HomeCategory({
    required this.name,
    required this.amount,
    required this.icon,
  });

  factory HomeCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return HomeCategory(
      name: json['name']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      icon: json['icon']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }
}