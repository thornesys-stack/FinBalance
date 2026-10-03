import '../../../core/domain/account/account_classification.dart';
import '../../../core/domain/account/account_status.dart';
import '../../../core/domain/account/asset_summary.dart';
import '../../../core/domain/account/credit_card_details.dart';
import '../../../core/domain/account/financial_account.dart';
import '../../../core/domain/account/financial_account_type.dart';
import '../../../core/domain/account/loan_details.dart';
import '../../../core/domain/sync/data_source.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

// Account Data Layer 与 Core Domain 之间的数据转换器。
class AccountMapper {
  const AccountMapper._();
  // FinancialAccount
  // 将 API 返回的数据转换为 FinancialAccount。
  //
  // 后端字段是 snake_case（backend/app/schemas/account.py 的 AccountOut）：
  //   {id: int, name, account_type, classification, currency,
  //    balance: {amount_minor, currency}, institution, status, data_source,
  //    connection_id, is_enabled, credit_details, last_synced_at, ...}
  static FinancialAccount financialAccountFromJson(Map<String, dynamic> json) {
    final currency = _currencyFromJson(json['currency']);

    return FinancialAccount(
      // 后端 id 是 int 主键，统一转字符串 —— Domain 层的 id 一直是 String。
      id: _requiredId(json['id']),

      name: _requiredString(json['name']),

      accountType: _financialAccountTypeFromJson(
        json['account_type'] ?? json['accountType'] ?? json['type'],
      ),

      classification: _accountClassificationFromJson(json['classification']),

      currency: currency,

      balance: _moneyFromJson(json['balance'], currency),

      institution: _nullableString(json['institution'] ?? json['providerName']),

      status: _accountStatusFromJson(json),

      dataSource: _dataSourceFromJson(
        json['data_source'] ?? json['dataSource'],
      ),

      lastSyncedAt: _dateTimeFromJson(
        json['last_synced_at'] ?? json['lastSyncedAt'],
      ),

      metadata: _metadataFromJson(json['metadata']),

      creditCardDetails: _creditCardDetailsFromJson(
        json['credit_details'] ?? json['creditCardDetails'],
      ),

      loanDetails: _loanDetailsFromJson(
        json['loan_details'] ?? json['loanDetails'],
      ),
    );
  }

  // AssetSummary
  // 将 GET /accounts/overview 的 data 转换为 AssetSummary [V1.1 §21]。
  //
  // 后端给的是**按 base_currency 折算后的单值**（服务端是权威口径，
  // 前端不重新计算），形状：
  //   {base_currency: "CNY",
  //    total_assets:      {amount_minor, currency},
  //    total_liabilities: {amount_minor, currency},
  //    net_worth:         {amount_minor, currency}, ...}
  // Domain 层要的是按币种分组的 Map，这里以各 Money 自带的币种为键（
  // 正常情况三者都等于 base_currency；缺汇率的账户不进统计，见 unconverted）。
  static AssetSummary assetSummaryFromJson(Map<String, dynamic> json) {
    final fallback = _fallbackCurrency(json['base_currency']);

    return AssetSummary(
      totalAssetsByCurrency: _singleMoneyAsMap(json['total_assets'], fallback),

      totalLiabilitiesByCurrency: _singleMoneyAsMap(
        json['total_liabilities'],
        fallback,
      ),

      netWorthByCurrency: _singleMoneyAsMap(json['net_worth'], fallback),
    );
  }

  /// 把单个 Money 对象包成 `{currencyCode: Money}`。
  ///
  /// 值为 null 时返回空 Map（与 V1.0 的「无数据」语义一致），
  /// 账户页据此显示「暂无数据」而不是 ¥0.00。
  static Map<String, Money> _singleMoneyAsMap(
    dynamic value,
    Currency fallback,
  ) {
    if (value == null) {
      return const {};
    }

    final money = _moneyFromJson(value, fallback);

    return {money.currency.code: money};
  }

  /// base_currency 兜底解析；缺失时用 CNY 而不是抛错 ——
  /// 聚合接口一定会返回它，这里只是防御。
  static Currency _fallbackCurrency(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return Currency.fromCode(value);
    }

    return Currency.cny;
  }

  // String
  /// 主键 id：后端是 int（SQLite 自增主键），Domain 层统一用 String。
  static String _requiredId(dynamic value) {
    if (value is int) {
      return value.toString();
    }

    if (value is num) {
      return value.toInt().toString();
    }

    return _requiredString(value);
  }

  static String _requiredString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    throw FormatException('Required string field is missing or invalid.');
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final result = value.trim();

      if (result.isEmpty) {
        return null;
      }

      return result;
    }

    return value.toString();
  }

  // DateTime
  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }

    return null;
  }

  // Metadata
  static Map<String, dynamic> _metadataFromJson(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  // Currency
  static Currency _currencyFromJson(dynamic value) {
    if (value is Currency) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      return Currency.fromCode(value);
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final code = map['code'];

      if (code is String && code.trim().isNotEmpty) {
        return Currency.fromCode(code);
      }
    }

    throw FormatException('Invalid currency value: $value');
  }

  // Money
  // 将 API 金额转换为 FinBalance Money。
  static Money _moneyFromJson(dynamic value, Currency fallbackCurrency) {
    // Map
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final currencyValue = map['currency'];

      final currency =
          currencyValue == null
              ? fallbackCurrency
              : _currencyFromJson(currencyValue);

      // 优先读取最小货币单位。后端（V1.1）是 snake_case 的 amount_minor，
      // amountMinor 是 V1.0 契约的旧写法，保留兼容。
      final amountMinor = map['amount_minor'] ?? map['amountMinor'];

      if (amountMinor is int) {
        return Money(amountMinor: amountMinor, currency: currency);
      }

      if (amountMinor is num) {
        return Money(amountMinor: amountMinor.round(), currency: currency);
      }
      // 如果后端返回 amount，
      // 则按照货币的小数位转换。
      final amount = map['amount'];

      if (amount is num) {
        return Money(
          amountMinor: _majorToMinor(amount, currency),
          currency: currency,
        );
      }
    }
    // int
    if (value is int) {
      return Money(
        amountMinor: _majorToMinor(value, fallbackCurrency),
        currency: fallbackCurrency,
      );
    }
    // double / num
    if (value is num) {
      return Money(
        amountMinor: _majorToMinor(value, fallbackCurrency),
        currency: fallbackCurrency,
      );
    }

    throw FormatException('Invalid money value: $value');
  }

  // 将主货币单位转换为最小货币单位。
  static int _majorToMinor(num amount, Currency currency) {
    var multiplier = 1;

    for (var i = 0; i < currency.decimalDigits; i++) {
      multiplier *= 10;
    }

    return (amount * multiplier).round();
  }

  // FinancialAccountType
  static FinancialAccountType _financialAccountTypeFromJson(dynamic value) {
    final normalized = _normalizeEnumValue(value);

    switch (normalized) {
      case 'bankaccount':
      case 'bank_account':
      case 'bank':
        return FinancialAccountType.bankAccount;

      case 'cash':
        return FinancialAccountType.cash;

      case 'ewallet':
      case 'e_wallet':
      case 'wallet':
      case 'digital_wallet':
        return FinancialAccountType.eWallet;

      case 'creditcard':
      case 'credit_card':
        return FinancialAccountType.creditCard;

      case 'investment':
      case 'investment_account':
        return FinancialAccountType.investment;

      case 'loan':
      case 'loan_account':
        return FinancialAccountType.loan;

      // V1.1 §10.1 的「其他资产 / 其他负债」：Domain 只有一个 other，
      // 不区分方向 —— 方向由 classification 表达，这里不丢信息。
      case 'other_asset':
      case 'other_liability':
        return FinancialAccountType.other;

      default:
        return FinancialAccountType.other;
    }
  }

  // AccountClassification
  static AccountClassification _accountClassificationFromJson(dynamic value) {
    final normalized = _normalizeEnumValue(value);

    switch (normalized) {
      case 'asset':
      case 'assets':
        return AccountClassification.asset;

      case 'liability':
      case 'liabilities':
        return AccountClassification.liability;

      default:
        return AccountClassification.asset;
    }
  }

  // AccountStatus
  static AccountStatus _accountStatusFromJson(Map<String, dynamic> json) {
    final value = json['status'];

    if (value != null) {
      final normalized = _normalizeEnumValue(value);

      switch (normalized) {
        case 'active':
        case 'enabled':
          return AccountStatus.active;

        case 'suspended':
        case 'paused':
          return AccountStatus.suspended;

        case 'closed':
          return AccountStatus.closed;

        case 'deleted':
          return AccountStatus.deleted;

        default:
          return AccountStatus.unknown;
      }
    }
    // 如果后端没有 status，
    // 尝试使用 isEnabled。
    final isEnabled = json['isEnabled'];

    if (isEnabled is bool) {
      return isEnabled ? AccountStatus.active : AccountStatus.suspended;
    }

    return AccountStatus.unknown;
  }

  // DataSource
  static DataSource _dataSourceFromJson(dynamic value) {
    final normalized = _normalizeEnumValue(value);

    switch (normalized) {
      case 'manual':
        return DataSource.manual;

      case 'wechat':
      case 'we_chat':
        return DataSource.wechat;

      case 'alipay':
      case 'ali_pay':
        return DataSource.alipay;

      case 'bank':
      case 'bank_api':
        return DataSource.bank;

      case 'creditcard':
      case 'credit_card':
        return DataSource.creditCard;

      case 'investment':
      case 'investmentplatform':
      case 'investment_platform':
        return DataSource.investmentPlatform;

      case 'file':
      case 'fileimport':
      case 'file_import':
        return DataSource.fileImport;

      case 'api':
      case 'sync':
        return DataSource.api;

      case 'other':
        return DataSource.other;

      default:
        return DataSource.unknown;
    }
  }

  // Enum normalization
  static String _normalizeEnumValue(dynamic value) {
    if (value is String) {
      return value.trim().toLowerCase();
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final name = map['name'];

      if (name is String) {
        return name.trim().toLowerCase();
      }

      final valueField = map['value'];

      if (valueField is String) {
        return valueField.trim().toLowerCase();
      }
    }

    return '';
  }

  // CreditCardDetails
  static CreditCardDetails? _creditCardDetailsFromJson(dynamic value) {
    if (value is! Map) {
      return null;
    }
    // 当前 CreditCardDetails 的具体 API
    // 字段尚未在当前 Domain/API Contract 中
    // 完成冻结，因此暂时不进行猜测性转换。
    return null;
  }

  // LoanDetails
  static LoanDetails? _loanDetailsFromJson(dynamic value) {
    if (value is! Map) {
      return null;
    }
    // 当前 LoanDetails 的具体 API
    // 字段尚未在当前 Domain/API Contract 中
    // 完成冻结，因此暂时不进行猜测性转换。
    return null;
  }
}
