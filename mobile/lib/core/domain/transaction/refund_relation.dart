import 'transaction_link.dart';

// 原始交易与退款交易之间的关系。
// 通过这个关系，系统可以知道退款对应哪一笔原始交易。
class RefundRelation extends TransactionLink {
  // 原始交易 ID。
  final String originalTransactionId;
  // 退款交易 ID。
  final String refundTransactionId;

  const RefundRelation({
    required super.id,
    required super.sourceTransactionId,
    required super.targetTransactionId,
    required super.createdAt,
    required this.originalTransactionId,
    required this.refundTransactionId,
  });

  @override
  String toString() {
    return 'RefundRelation('
        'id: $id, '
        'originalTransactionId: $originalTransactionId, '
        'refundTransactionId: $refundTransactionId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RefundRelation &&
        other.id == id &&
        other.sourceTransactionId == sourceTransactionId &&
        other.targetTransactionId == targetTransactionId &&
        other.originalTransactionId == originalTransactionId &&
        other.refundTransactionId == refundTransactionId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sourceTransactionId,
      targetTransactionId,
      originalTransactionId,
      refundTransactionId,
    );
  }
}
