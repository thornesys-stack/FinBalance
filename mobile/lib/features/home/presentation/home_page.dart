import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../data/home_repository.dart';
import '../domain/home_overview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ApiClient _apiClient;
  late final HomeRepository _repository;

  HomeOverview? _overview;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _repository = HomeRepository(apiClient: _apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final overview = await _repository.fetchOverview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '暂时无法连接服务器，请稍后重试。';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _overview;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          _buildGreeting(),
          const SizedBox(height: 18),
          _buildAssetCard(data),
          const SizedBox(height: 14),
          _buildCashFlowCard(data),
          const SizedBox(height: 14),
          _buildRiskCard(),
          const SizedBox(height: 14),
          _buildAiSummaryCard(data),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '资产总览',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 5),
        Text(
          '清晰知道你的钱在哪里，以及最近发生了什么。',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(HomeOverview? data) {
    final hasAssetData = data?.totalAssets != null;
    final hasNetWorth = data?.netWorth != null;
    final hasLiability = data?.totalLiabilities != null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3157E8),
            Color(0xFF5477F2),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x243157E8),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white70,
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                '总资产',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _money(
              data?.totalAssets,
              currency: data?.baseCurrency ?? 'CNY',
              placeholder: hasAssetData ? null : '—',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          if (!hasAssetData && !_loading)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '等待资产账户接口提供实时总资产',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _assetMetric(
                  '净资产',
                  _money(
                    data?.netWorth,
                    currency: data?.baseCurrency ?? 'CNY',
                    placeholder: hasNetWorth ? null : '—',
                  ),
                ),
              ),
              Expanded(
                child: _assetMetric(
                  '总负债',
                  _money(
                    data?.totalLiabilities,
                    currency: data?.baseCurrency ?? 'CNY',
                    placeholder: hasLiability ? null : '—',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetMetric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCashFlowCard(HomeOverview? data) {
    return _sectionCard(
      title: '本期资金流',
      icon: Icons.swap_vert_rounded,
      child: Row(
        children: [
          Expanded(
            child: _flowItem(
              '收入',
              _money(data?.income, currency: data?.baseCurrency ?? 'CNY'),
              Icons.south_west_rounded,
            ),
          ),
          Expanded(
            child: _flowItem(
              '支出',
              _money(data?.expense, currency: data?.baseCurrency ?? 'CNY'),
              Icons.north_east_rounded,
            ),
          ),
          Expanded(
            child: _flowItem(
              '结余',
              _money(
                data?.periodBalance,
                currency: data?.baseCurrency ?? 'CNY',
              ),
              Icons.account_balance_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCard() {
    return _sectionCard(
      title: '账户安全',
      icon: Icons.shield_outlined,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF2E9B59),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '暂无已接入的风险事件。后续 AI 将根据交易时间、地点、金额等信号进行风险检测。',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSummaryCard(HomeOverview? data) {
    final summary = data?.aiSummary;
    return _sectionCard(
      title: 'AI 财务摘要',
      icon: Icons.auto_awesome_rounded,
      child: Text(
        summary?.isNotEmpty == true
            ? summary!
            : 'AI 财务摘要将在后端提供分析结果后显示。这里不会使用虚构的分析内容。',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9EDF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _money(
    double? value, {
    required String currency,
    String? placeholder,
  }) {
    if (value == null) return placeholder ?? '—';
    final symbol = switch (currency.toUpperCase()) {
      'CNY' => '¥',
      'USD' => '\$',
      'JPY' => '¥',
      'EUR' => '€',
      'GBP' => '£',
      _ => currency.toUpperCase(),
    };
    return '$symbol${value.toStringAsFixed(2)}';
  }
}
