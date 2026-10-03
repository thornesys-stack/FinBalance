import '../../money/money.dart';

// FinBalance 资产负债汇总。
// 用于描述用户当前的资产、负债以及净资产。
class AssetSummary {
  // 各币种对应的资产总额。
  final Map<String, Money> totalAssetsByCurrency;
  // 各币种对应的负债总额。
  final Map<String, Money> totalLiabilitiesByCurrency;
  // 各币种对应的净资产。
  final Map<String, Money> netWorthByCurrency;

  const AssetSummary({
    this.totalAssetsByCurrency = const {},
    this.totalLiabilitiesByCurrency = const {},
    this.netWorthByCurrency = const {},
  });
  // 是否存在资产数据。
  bool get hasAssets => totalAssetsByCurrency.isNotEmpty;
  // 是否存在负债数据。
  bool get hasLiabilities => totalLiabilitiesByCurrency.isNotEmpty;
  // 是否存在净资产数据。
  bool get hasNetWorth => netWorthByCurrency.isNotEmpty;

  AssetSummary copyWith({
    Map<String, Money>? totalAssetsByCurrency,
    Map<String, Money>? totalLiabilitiesByCurrency,
    Map<String, Money>? netWorthByCurrency,
  }) {
    return AssetSummary(
      totalAssetsByCurrency:
          totalAssetsByCurrency ?? this.totalAssetsByCurrency,
      totalLiabilitiesByCurrency:
          totalLiabilitiesByCurrency ?? this.totalLiabilitiesByCurrency,
      netWorthByCurrency: netWorthByCurrency ?? this.netWorthByCurrency,
    );
  }

  @override
  String toString() {
    return 'AssetSummary('
        'totalAssetsByCurrency: $totalAssetsByCurrency, '
        'totalLiabilitiesByCurrency: $totalLiabilitiesByCurrency, '
        'netWorthByCurrency: $netWorthByCurrency'
        ')';
  }
}
