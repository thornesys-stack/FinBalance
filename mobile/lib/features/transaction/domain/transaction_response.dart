import 'transaction.dart';

class TransactionResponse {
  final List<FinancialTransaction> items;
  final int total;

  const TransactionResponse({
    required this.items,
    required this.total,
  });

  factory TransactionResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'] as List? ?? [];

    return TransactionResponse(
      items: rawItems
          .map(
            (item) => FinancialTransaction.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}