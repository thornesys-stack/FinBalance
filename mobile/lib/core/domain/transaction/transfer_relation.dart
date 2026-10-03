import 'transaction_link.dart';

// 两笔交易之间的转账关系。
// TransferRelation 用来描述这两笔交易属于同一次转账。
class TransferRelation extends TransactionLink {
  // 发起转账的账户 ID。
  final String sourceAccountId;
  // 接收转账的账户 ID。
  final String targetAccountId;

  const TransferRelation({
    required super.id,
    required super.sourceTransactionId,
    required super.targetTransactionId,
    required super.createdAt,
    required this.sourceAccountId,
    required this.targetAccountId,
  });

  @override
  String toString() {
    return 'TransferRelation('
        'id: $id, '
        'sourceTransactionId: $sourceTransactionId, '
        'targetTransactionId: $targetTransactionId, '
        'sourceAccountId: $sourceAccountId, '
        'targetAccountId: $targetAccountId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TransferRelation &&
        other.id == id &&
        other.sourceTransactionId == sourceTransactionId &&
        other.targetTransactionId == targetTransactionId &&
        other.sourceAccountId == sourceAccountId &&
        other.targetAccountId == targetAccountId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sourceTransactionId,
      targetTransactionId,
      sourceAccountId,
      targetAccountId,
    );
  }
}
