import '../../../core/constants/api_endpoints.dart';
import '../../../core/domain/transaction/transaction_domain.dart';
import '../../../core/domain/sync/data_source.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/network/api_client.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<TransactionPage> getTransactions({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 后端路径是 /bills [V1.1 §48]；旧的 /transactions 是 404。
    // 查询参数全部 snake_case：传 pageSize 会被 FastAPI 静默忽略、
    // 退回 page_size 默认值（后端 bills.py 的注释专门警告过这个坑）。
    final response = await _apiClient.get(
      ApiEndpoints.bills,
      queryParameters: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    final data = _extractData(response);

    final rawItems = data['items'];

    final items = <Transaction>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(_transactionFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return TransactionPage(
      items: items,
      page: _toInt(data['page'], page),
      pageSize: _toInt(data['pageSize'] ?? data['page_size'], pageSize),
      total: _toInt(data['total'], items.length),
    );
  }

  /// 收支汇总。
  ///
  /// 后端**没有** `/transactions/summary`（V1.0 的路径，V1.1 已删），
  /// 等价数据在 /analysis/overview 里：income / expense / net_cash_flow /
  /// bill_count，口径是「当前统计周期」（默认本月，用户时区）。
  Future<TransactionSummary> getSummary() async {
    final response = await _apiClient.get(ApiEndpoints.analysisOverview);

    final data = _extractData(response);

    final currency = _currencyFromJson(data['base_currency']);

    final income = _moneyFromJson(data['income'], currency);

    final expense = _moneyFromJson(data['expense'], currency);

    final balance = _moneyFromJson(data['net_cash_flow'], currency);

    return TransactionSummary(
      income: income,
      expense: expense,
      balance: balance,
      transactionCount: _toInt(
        data['bill_count'] ?? data['transactionCount'] ?? data['billCount'],
        0,
      ),
    );
  }

  // Transaction Mapper
  //
  // 后端字段是 snake_case（backend/app/schemas/transaction.py 的 TransactionOut）：
  //   {id: int, account_id, type, status,
  //    amount: {amount_minor, currency}, merchant, category_code, category_name,
  //    description, occurred_at, payment_method, data_source,
  //    related_transaction_id, link_type, ...}
  Transaction _transactionFromJson(Map<String, dynamic> json) {
    final currency = _currencyFromJson(json['currency']);

    final amount = _moneyFromJson(json['amount'], currency);

    return Transaction(
      id: json['id']?.toString() ?? '',
      accountId: (json['account_id'] ?? json['accountId'])?.toString(),
      type: _transactionTypeFromJson(json['type']),
      status: _transactionStatusFromJson(json['status']),
      amount: amount,
      merchant: json['merchant']?.toString(),
      category: TransactionCategory.simple(
        // 展示名优先 category_name，缺失时退回稳定的 category_code。
        _firstText(json['category_name'], json['category_code']) ?? '其他',
      ),
      occurredAt: _dateTimeFromJson(
        json['occurred_at'] ?? json['occurredAt'] ?? json['date'],
      ),
      description: json['description']?.toString(),
      source: _dataSourceFromJson(json['data_source'] ?? json['source']),
      relatedTransactionId:
          (json['related_transaction_id'] ?? json['relatedTransactionId'])
              ?.toString(),
      anomaly: json['anomaly'] == true,
      metadata: _metadataFromJson(json['metadata']),
    );
  }

  /// 取第一个非空文本。
  static String? _firstText(dynamic a, dynamic b) {
    for (final value in [a, b]) {
      final text = value?.toString().trim();

      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  // Response Envelope
  Map<String, dynamic> _extractData(dynamic response) {
    if (response is! Map) {
      return {};
    }

    final map = Map<String, dynamic>.from(response);

    final data = map['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return map;
  }

  // Currency
  Currency _currencyFromJson(dynamic value) {
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
    // 当前 Bills Contract 尚未要求
    return Currency.cny;
  }

  // Money
  Money _moneyFromJson(dynamic value, Currency currency) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      // V1.1 是 snake_case 的 amount_minor；amountMinor 是 V1.0 旧写法。
      final amountMinor = map['amount_minor'] ?? map['amountMinor'];

      if (amountMinor is int) {
        return Money(amountMinor: amountMinor, currency: currency);
      }

      if (amountMinor is num) {
        return Money(amountMinor: amountMinor.round(), currency: currency);
      }

      final amount = map['amount'];

      if (amount is num) {
        return Money(
          amountMinor: _majorToMinor(amount, currency),
          currency: currency,
        );
      }
    }

    if (value is num) {
      return Money(
        amountMinor: _majorToMinor(value, currency),
        currency: currency,
      );
    }

    return Money(amountMinor: 0, currency: currency);
  }

  int _majorToMinor(num amount, Currency currency) {
    var multiplier = 1;

    for (var i = 0; i < currency.decimalDigits; i++) {
      multiplier *= 10;
    }

    return (amount * multiplier).round();
  }

  // Transaction Type
  TransactionType _transactionTypeFromJson(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'income':
        return TransactionType.income;

      case 'expense':
        return TransactionType.expense;

      case 'transfer':
        return TransactionType.transfer;

      case 'refund':
        return TransactionType.refund;

      default:
        return TransactionType.expense;
    }
  }

  // Transaction Status
  //
  // 后端（V1.1 §16）：pending / confirmed / needs_review / invalid。
  // Domain 枚举：completed / pending / cancelled / deleted。
  // 映射语义：confirmed→completed（已确认）；needs_review→pending
  // （「疑似转账待确认」在 UI 上按待处理展示）；invalid→cancelled（作废）。
  TransactionStatus _transactionStatusFromJson(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'pending':
      case 'needs_review':
        return TransactionStatus.pending;

      case 'cancelled':
      case 'canceled':
      case 'invalid':
        return TransactionStatus.cancelled;

      case 'deleted':
        return TransactionStatus.deleted;

      case 'confirmed':
      case 'completed':
      default:
        return TransactionStatus.completed;
    }
  }

  // Data Source
  DataSource? _dataSourceFromJson(dynamic value) {
    if (value == null) {
      return null;
    }

    switch (value.toString().trim().toLowerCase()) {
      case 'wechat':
        return DataSource.wechat;

      case 'alipay':
        return DataSource.alipay;

      case 'bank':
        return DataSource.bank;

      case 'manual':
        return DataSource.manual;

      case 'file':
      case 'file_import':
        return DataSource.fileImport;

      case 'api':
        return DataSource.api;

      default:
        return DataSource.unknown;
    }
  }

  // DateTime
  DateTime _dateTimeFromJson(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final parsed = DateTime.tryParse(value?.toString() ?? '');

    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  // Metadata
  Map<String, dynamic> _metadataFromJson(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  // Integer
  int _toInt(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
