import 'financial_account.dart';
import 'asset_summary.dart';

// FinBalance 账户总览。
// 用于描述用户当前所有金融账户，以及这些账户形成的资产、负债和净资产汇总。
class AccountOverview {
  /// 当前用户拥有的金融账户。
  final List<FinancialAccount> accounts;

  /// 当前账户体系的资产负债汇总。
  final AssetSummary summary;

  const AccountOverview({
    this.accounts = const [],
    this.summary = const AssetSummary(),
  });
  // 当前是否存在账户。
  bool get hasAccounts => accounts.isNotEmpty;
  // 当前账户数量。
  int get accountCount => accounts.length;
  // 当前处于正常状态的账户。
  List<FinancialAccount> get activeAccounts {
    return accounts
        .where((account) => account.isActive)
        .toList(growable: false);
  }

  // 当前资产账户。
  List<FinancialAccount> get assetAccounts {
    return accounts.where((account) => account.isAsset).toList(growable: false);
  }

  // 当前负债账户。
  List<FinancialAccount> get liabilityAccounts {
    return accounts
        .where((account) => account.isLiability)
        .toList(growable: false);
  }

  // 当前信用卡账户。
  List<FinancialAccount> get creditCardAccounts {
    return accounts
        .where((account) => account.isCreditCard)
        .toList(growable: false);
  }

  // 当前贷款账户。
  List<FinancialAccount> get loanAccounts {
    return accounts.where((account) => account.isLoan).toList(growable: false);
  }

  // 是否存在资产。
  bool get hasAssets => summary.hasAssets;
  // 是否存在负债。
  bool get hasLiabilities => summary.hasLiabilities;
  // 是否存在净资产数据。
  bool get hasNetWorth => summary.hasNetWorth;

  AccountOverview copyWith({
    List<FinancialAccount>? accounts,
    AssetSummary? summary,
  }) {
    return AccountOverview(
      accounts: accounts ?? this.accounts,
      summary: summary ?? this.summary,
    );
  }

  @override
  String toString() {
    return 'AccountOverview('
        'accounts: $accounts, '
        'summary: $summary'
        ')';
  }
}
