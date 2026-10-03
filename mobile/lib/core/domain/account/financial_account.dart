import 'account_classification.dart';
import 'account_status.dart';
import 'financial_account_type.dart';
import 'credit_card_details.dart';
import 'loan_details.dart';
import '../../money/currency.dart';
import '../../money/money.dart';
import '../sync/data_source.dart';

// FinBalance 金融账户。
// FinancialAccount 描述用户持有或使用的一个金融账户。
class FinancialAccount {
  // 账户唯一 ID。
  final String id;
  // 账户名称。
  final String name;
  // 账户类型。
  final FinancialAccountType accountType;
  // 资产 / 负债分类。
  final AccountClassification classification;
  // 账户货币。
  final Currency currency;
  // 当前余额。
  final Money balance;
  // 金融机构名称。
  final String? institution;
  // 账户状态。
  final AccountStatus status;
  // 数据来源。
  final DataSource dataSource;
  // 最近一次同步时间。
  final DateTime? lastSyncedAt;
  // 额外元数据。
  // 给后续银行、信用卡、投资账户等扩展信息留下空间。
  final Map<String, dynamic> metadata;
  // 信用卡专属信息。
  final CreditCardDetails? creditCardDetails;
  // 贷款账户专属信息。
  final LoanDetails? loanDetails;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.accountType,
    required this.classification,
    required this.currency,
    required this.balance,
    this.institution,
    required this.status,
    required this.dataSource,
    this.lastSyncedAt,
    this.metadata = const {},
    this.creditCardDetails,
    this.loanDetails,
  });
  // 判断当前账户是否为资产账户。
  bool get isAsset => classification == AccountClassification.asset;
  // 判断当前账户是否为负债账户。
  bool get isLiability => classification == AccountClassification.liability;
  // 判断当前账户是否处于正常状态。
  bool get isActive => status == AccountStatus.active;
  // 当前账户是否为信用卡。
  bool get isCreditCard => accountType == FinancialAccountType.creditCard;
  // 当前账户是否为贷款。
  bool get isLoan => accountType == FinancialAccountType.loan;
  // 创建当前账户的副本。
  FinancialAccount copyWith({
    String? id,
    String? name,
    FinancialAccountType? accountType,
    AccountClassification? classification,
    Currency? currency,
    Money? balance,
    String? institution,
    AccountStatus? status,
    DataSource? dataSource,
    DateTime? lastSyncedAt,
    Map<String, dynamic>? metadata,
    CreditCardDetails? creditCardDetails,
    LoanDetails? loanDetails,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      classification: classification ?? this.classification,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      institution: institution ?? this.institution,
      status: status ?? this.status,
      dataSource: dataSource ?? this.dataSource,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      metadata: metadata ?? this.metadata,
      creditCardDetails: creditCardDetails ?? this.creditCardDetails,
      loanDetails: loanDetails ?? this.loanDetails,
    );
  }

  @override
  String toString() {
    return 'FinancialAccount('
        'id: $id, '
        'name: $name, '
        'accountType: $accountType, '
        'classification: $classification, '
        'currency: ${currency.code}, '
        'balance: $balance, '
        'status: $status, '
        'dataSource: $dataSource'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FinancialAccount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
