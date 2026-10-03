import 'transaction.dart';

// 交易分页结果。
class TransactionPage {
  final List<Transaction> items;

  final int page;

  final int pageSize;

  final int total;

  const TransactionPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  // 是否还有下一页。
  bool get hasNextPage => page * pageSize < total;

  // 当前页是否为空。
  bool get isEmpty => items.isEmpty;

  // 当前页是否有数据。
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'TransactionPage('
        'items: ${items.length}, '
        'page: $page, '
        'pageSize: $pageSize, '
        'total: $total'
        ')';
  }
}
