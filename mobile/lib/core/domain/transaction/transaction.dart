import '../../money/currency.dart';
import '../../money/money.dart';
import '../sync/data_source.dart';
import 'payment_method.dart';
import 'transaction_category.dart';
import 'transaction_status.dart';
import 'transaction_type.dart';

// FinBalance 核心金融交易模型。
class Transaction {
  // 交易唯一 ID。
  final String id;
  // 所属金融账户 ID。
  final String? accountId;
  // 交易类型。
  final TransactionType type;
  // 交易状态。
  final TransactionStatus status;
  // 交易金额。
  final Money amount;
  // 交易货币。
  Currency get currency => amount.currency;
  // 商户名称。
  final String? merchant;
  // 交易分类。
  final TransactionCategory category;
  // 交易发生时间。
  final DateTime occurredAt;
  // 交易描述。
  final String? description;
  // 支付方式。
  final PaymentMethod? paymentMethod;
  // 数据来源。
  final DataSource? source;
  // 关联交易 ID。
  final String? relatedTransactionId;
  // AI 分类信息。
  final AIClassification? aiClassification;
  // 是否被识别为异常交易。
  final bool anomaly;
  // 其他扩展元数据。
  final Map<String, dynamic> metadata;

  const Transaction({
    required this.id,
    this.accountId,
    required this.type,
    required this.status,
    required this.amount,
    this.merchant,
    required this.category,
    required this.occurredAt,
    this.description,
    this.paymentMethod,
    this.source,
    this.relatedTransactionId,
    this.aiClassification,
    this.anomaly = false,
    this.metadata = const {},
  });
  // 是否为收入。
  bool get isIncome => type == TransactionType.income;

  // 是否为支出。
  bool get isExpense => type == TransactionType.expense;

  // 是否为转账。
  bool get isTransfer => type == TransactionType.transfer;

  // 是否为退款。
  bool get isRefund => type == TransactionType.refund;

  // 是否为已完成交易。
  bool get isCompleted => status == TransactionStatus.completed;

  // 创建当前交易的副本。
  Transaction copyWith({
    String? id,
    String? accountId,
    TransactionType? type,
    TransactionStatus? status,
    Money? amount,
    String? merchant,
    TransactionCategory? category,
    DateTime? occurredAt,
    String? description,
    PaymentMethod? paymentMethod,
    DataSource? source,
    String? relatedTransactionId,
    AIClassification? aiClassification,
    bool? anomaly,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      occurredAt: occurredAt ?? this.occurredAt,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      source: source ?? this.source,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      aiClassification: aiClassification ?? this.aiClassification,
      anomaly: anomaly ?? this.anomaly,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Transaction('
        'id: $id, '
        'accountId: $accountId, '
        'type: $type, '
        'status: $status, '
        'amount: $amount, '
        'merchant: $merchant, '
        'category: ${category.name}, '
        'occurredAt: $occurredAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// AI 交易分类结果。
class AIClassification {
  // AI 判断出的分类。
  final String category;
  // 置信度。
  final double confidence;
  // AI 判断解释。
  final String? explanation;

  const AIClassification({
    required this.category,
    required this.confidence,
    this.explanation,
  });

  @override
  String toString() {
    return 'AIClassification('
        'category: $category, '
        'confidence: $confidence, '
        'explanation: $explanation'
        ')';
  }
}
