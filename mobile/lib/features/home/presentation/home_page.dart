import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../data/home_repository.dart';
import '../domain/home_overview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeRepository _repository = HomeRepository();

  late Future<HomeOverview> _futureOverview;

  @override
  void initState() {
    super.initState();

    _futureOverview = _repository.getOverview();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureOverview = _repository.getOverview();
    });

    await _futureOverview;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<HomeOverview>(
          future: _futureOverview,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final overview = snapshot.data;

            if (overview == null) {
              return const Center(child: Text('暂无财务数据'));
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'FinBalance',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  '掌握你的每一笔财务变化',
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                _BalanceCard(overview: overview),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: '收入',
                        amount: overview.income,
                        icon: Icons.arrow_downward,
                        color: AppColors.income,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: '支出',
                        amount: overview.expense,
                        icon: Icons.arrow_upward,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.savings_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            '储蓄率',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${overview.savingsRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final HomeOverview overview;

  const _BalanceCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3157D5), Color(0xFF6B7FE8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本期结余', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(overview.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(
              CurrencyFormatter.format(amount),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              '无法获取财务数据',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('重新加载')),
          ],
        ),
      ),
    );
  }
}
