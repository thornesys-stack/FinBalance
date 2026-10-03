import 'package:flutter/material.dart';

import '../../../core/domain/transaction/transaction_domain.dart';
import '../data/transaction_repository.dart';

class TransactionPage extends StatefulWidget {
  final TransactionRepository transactionRepository;

  const TransactionPage({super.key, required this.transactionRepository});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool _isLoading = true;

  List<Transaction> _transactions = [];

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.transactionRepository.getTransactions();

      if (!mounted) {
        return;
      }

      setState(() {
        _transactions = response.items;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage = '暂时无法加载账单数据';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账单')),
      body: RefreshIndicator(onRefresh: _loadTransactions, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 180),
          Center(
            child: Column(
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadTransactions,
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 52),
                SizedBox(height: 16),
                Text('暂时没有账单'),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];

        return _TransactionItem(transaction: transaction);
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    final isRefund = transaction.type == TransactionType.refund;

    final isTransfer = transaction.type == TransactionType.transfer;

    final amount = _formatAmount(transaction);

    String prefix = '-';

    if (isIncome || isRefund) {
      prefix = '+';
    }

    if (isTransfer) {
      prefix = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconForTransaction(transaction))),
        title: Text(
          transaction.merchant?.isNotEmpty == true
              ? transaction.merchant!
              : transaction.category.name,
        ),
        subtitle: Text(transaction.description ?? transaction.category.name),
        trailing: Text(
          '$prefix$amount',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _colorForTransaction(context, transaction),
          ),
        ),
      ),
    );
  }

  IconData _iconForTransaction(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward;

      case TransactionType.expense:
        return Icons.arrow_upward;

      case TransactionType.transfer:
        return Icons.swap_horiz;

      case TransactionType.refund:
        return Icons.undo;
    }
  }

  Color _colorForTransaction(BuildContext context, Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.income:
      case TransactionType.refund:
        return Colors.green;

      case TransactionType.expense:
        return Colors.red;

      case TransactionType.transfer:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatAmount(Transaction transaction) {
    final money = transaction.amount;

    final currency = money.currency;

    var divisor = 1;

    for (var i = 0; i < currency.decimalDigits; i++) {
      divisor *= 10;
    }

    final major = money.amountMinor / divisor;

    return '${currency.symbol}'
        '${major.toStringAsFixed(currency.decimalDigits)}';
  }
}
