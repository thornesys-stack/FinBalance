import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: '交易',
      subtitle: '交易模型已经开始按收入、支出、转账与风险分析设计。',
      icon: Icons.receipt_long_rounded,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Icon(icon, size: 42, color: const Color(0xFF3157E8)),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7D8799),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
