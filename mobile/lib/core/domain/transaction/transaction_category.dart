// FinBalance 交易分类。
class TransactionCategory {
  final String id;
  final String name;
  final String? icon;

  const TransactionCategory({required this.id, required this.name, this.icon});
  // 创建一个最简单的分类。
  factory TransactionCategory.simple(String name, {String? icon}) {
    return TransactionCategory(id: name, name: name, icon: icon);
  }

  @override
  String toString() {
    return 'TransactionCategory('
        'id: $id, '
        'name: $name, '
        'icon: $icon'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TransactionCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
