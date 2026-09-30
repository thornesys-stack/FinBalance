import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_response.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() =>
      _TransactionPageState();
}

class _TransactionPageState
    extends State<TransactionPage> {
  final TransactionRepository _repository =
      TransactionRepository();

  late Future<TransactionResponse>
      _futureTransactions;

  @override
  void initState() {
    super.initState();

    _futureTransactions =
        _repository.getTransactions();
  }

  void _reload() {
    setState(() {
      _futureTransactions =
          _repository.getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<TransactionResponse>(
        future: _futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: _reload,
                child: const Text('加载失败，重新加载'),
              ),
            );
          }

          final response = snapshot.data;

          if (response == null ||
              response.items.isEmpty) {
            return const Center(
              child: Text('暂无交易记录'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                '收支流水',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ...response.items.map(
                (transaction) =>
                    _TransactionItem(
                  transaction: transaction,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final FinancialTransaction transaction;

  const _TransactionItem({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome =
        transaction.type.toLowerCase() == 'income';

    final color = isIncome
        ? AppColors.income
        : AppColors.expense;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${transaction.category} · ${DateFormatter.format(transaction.date)}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}