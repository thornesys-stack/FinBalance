// 两笔金融交易之间的关联关系。
// TransactionLink 是一个通用关系模型。
class TransactionLink {
  // 当前关系的唯一 ID。
  final String id;
  // 关系中的第一笔交易 ID。
  final String sourceTransactionId;
  // 关系中的第二笔交易 ID。
  final String targetTransactionId;
  // 创建时间。
  final DateTime createdAt;

  const TransactionLink({
    required this.id,
    required this.sourceTransactionId,
    required this.targetTransactionId,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'TransactionLink('
        'id: $id, '
        'sourceTransactionId: $sourceTransactionId, '
        'targetTransactionId: $targetTransactionId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TransactionLink &&
        other.id == id &&
        other.sourceTransactionId == sourceTransactionId &&
        other.targetTransactionId == targetTransactionId;
  }

  @override
  int get hashCode {
    return Object.hash(id, sourceTransactionId, targetTransactionId);
  }
}
