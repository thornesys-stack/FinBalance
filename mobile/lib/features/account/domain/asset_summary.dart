class AssetSummary {
  final double totalAssets;
  final double totalLiabilities;
  final double netAssets;

  const AssetSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netAssets,
  });

  factory AssetSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssetSummary(
      totalAssets: _toDouble(json['total_assets']),
      totalLiabilities:
          _toDouble(json['total_liabilities']),
      netAssets: _toDouble(json['net_assets']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}