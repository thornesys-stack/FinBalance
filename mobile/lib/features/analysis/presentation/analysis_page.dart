import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../data/analysis_repository.dart';
import '../domain/analysis_overview.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() =>
      _AnalysisPageState();
}

class _AnalysisPageState
    extends State<AnalysisPage> {
  final AnalysisRepository _repository =
      AnalysisRepository();

  late Future<AnalysisOverview> _futureAnalysis;

  @override
  void initState() {
    super.initState();

    _futureAnalysis =
        _repository.getAnalysis();
  }

  void _reload() {
    setState(() {
      _futureAnalysis =
          _repository.getAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<AnalysisOverview>(
        future: _futureAnalysis,
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
                child: const Text('重新加载'),
              ),
            );
          }

          final analysis = snapshot.data;

          if (analysis == null) {
            return const Center(
              child: Text('暂无分析数据'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                '财务分析',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _MetricCard(
                title: '总收入',
                value:
                    CurrencyFormatter.format(
                  analysis.totalIncome,
                ),
              ),

              const SizedBox(height: 12),

              _MetricCard(
                title: '总支出',
                value:
                    CurrencyFormatter.format(
                  analysis.totalExpense,
                ),
              ),

              const SizedBox(height: 12),

              _MetricCard(
                title: '储蓄率',
                value:
                    '${analysis.savingsRate.toStringAsFixed(1)}%',
              ),

              const SizedBox(height: 24),

              const Text(
                '支出分类',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...analysis.categories.map(
                (category) =>
                    _CategoryItem(
                  category: category,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryAnalysis category;

  const _CategoryItem({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(category.category),
        subtitle: LinearProgressIndicator(
          value: (category.percentage / 100)
              .clamp(0, 1),
        ),
        trailing: Text(
          CurrencyFormatter.format(
            category.amount,
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}